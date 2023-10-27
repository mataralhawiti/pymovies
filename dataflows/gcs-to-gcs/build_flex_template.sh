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
export TEMPLATE_IMAGE="${REGION}-docker.pkg.dev/${GCP_PROJECT}/dataflows/gcs-gcs-v1:v1"


## create artifacts repository
gcloud artifacts repositories create dataflows --location=${REGION} --repository-format=docker

## Build the image into Container Registry, this is roughly equivalent to:
#   gcloud auth configure-docker
#   docker image build -t $TEMPLATE_IMAGE .
#   docker push $TEMPLATE_IMAGE
gcloud builds submit --tag "$TEMPLATE_IMAGE" dataflows/gcs-to-gcs



# Creating a Flex Template
# ------------------------
export BUCKET="dataflows-useast1-00111001-dev"
export TEMPLATE_PATH="gs://$BUCKET/templates/gcs-to-gcs/gcs-gcs.json"

# Build the Flex Template.
gcloud dataflow flex-template build $TEMPLATE_PATH \
  --image "$TEMPLATE_IMAGE" \
  --sdk-language "PYTHON" \
  --metadata-file "metadata.json"


# Run a Dataflow Flex Template pipeline
gcloud dataflow flex-template run "gcs-to-gcs-beam-`date +%Y%m%d-%H%M%S`" \
    --template-file-gcs-location "$TEMPLATE_PATH" \
    --project=${GCP_PROJECT} \
    --region=${REGION}



