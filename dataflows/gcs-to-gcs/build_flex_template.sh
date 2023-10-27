# Set envs - 9
export GCP_PROJECT="$(gcloud config get-value project)" \
export REGION=us-east1
export _REGION=useast1
export ENV=dev

# Build stage
# -----------
## (Optional) Enable to use Kaniko cache by default.
gcloud config set builds/use_kaniko True

## set env vars
export TEMPLATE_IMAGE="${REGION}-docker.pkg.dev/${GCP_PROJECT}/dataflows/gcs-to-gcs:v1"


## create artifacts repository
gcloud artifacts repositories create dataflows --location=${REGION} --repository-format=docker

## Build the image into Container Registry, this is roughly equivalent to:
#   gcloud auth configure-docker
#   docker image build -t $TEMPLATE_IMAGE .
#   docker push $TEMPLATE_IMAGE
gcloud builds submit --tag "$TEMPLATE_IMAGE" dataflows/gcs-to-gcs



# Creating a Flex Template - Only for GCP Dataflow NOT Apache Beam
# ----------------------------------------------------------------
export BUCKET="dataflows-useast1-00111001-dev"
export TEMPLATE_PATH="gs://$BUCKET/templates/gcs-to-gcs/gcs-to-gcs.json"

# Build the Flex Template.
gcloud dataflow flex-template build $TEMPLATE_PATH \
  --image="$TEMPLATE_IMAGE" \
  --sdk-language="PYTHON" \
  --metadata-file="dataflows/gcs-to-gcs/metadata.json"


# Run a Dataflow Flex Template pipeline - ! --staging-location NOT --staging_location
# -----------------------------------------------------------------------------------
gcloud dataflow flex-template run "gcs-to-gcs-beam-`date +%Y%m%d-%H%M%S`" \
    --template-file-gcs-location "$TEMPLATE_PATH" \
    --project=${GCP_PROJECT} \
    --region=${REGION} \
    --staging-location=gs://${BUCKET}/staging \
    --parameters=output=gs://matar-useast1-00111001-dev/dest/names


# Clean up
# --------
## Stop the Dataflow pipeline
gcloud dataflow jobs list \
    --filter 'STATE=Running' \
    --format 'value(JOB_ID)' \
    --region "$REGION" \
  | xargs gcloud dataflow jobs cancel --region "$REGION"

## Delete the template spec file from Cloud Storage
gsutil rm $TEMPLATE_PATH

## Clean up our dataflow bucket
gsutil rm -a gs://${BUCKET}/**

## Delete the Flex Template container image
gcloud artifacts docker images delete $TEMPLATE_IMAGE --delete-tags