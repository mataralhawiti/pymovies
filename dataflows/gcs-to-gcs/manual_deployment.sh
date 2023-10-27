# Set envs - 9
# ------------
export GCP_PROJECT="$(gcloud config get-value project)" \
export REGION=us-east1
export _REGION=useast1
export ENV=dev

# GCS buckets
# -----------
## - create
gcloud storage buckets create gs://matar-${_REGION}-00111001-${ENV}  \
--project=${GCP_PROJECT}  \
--default-storage-class=STANDARD \
--location=${REGION} \
--uniform-bucket-level-access \
--no-public-access-prevention

gcloud storage buckets create gs://dataflows-${_REGION}-00111001-${ENV}  \
--project=${GCP_PROJECT}  \
--default-storage-class=STANDARD \
--location=${REGION} \
--uniform-bucket-level-access \
--no-public-access-prevention

## - set 
export BUCKET="dataflows-useast1-00111001-dev"


## upload
### single file
gcloud storage cp resource/sample2.json gs://matar-useast1-00111001-dev/source/sample2.json

### entire dir
gcloud storage cp -r resource/movies gs://matar-useast1-00111001-dev/source/movies


# enable dataflow API
gcloud services enable dataflow

# Run manually
# -------------
python3 dataflows/gcs_to_gcs_v1.py \
    --project=${GCP_PROJECT} \
    --region=${REGION} \
    --runner=DataflowRunner \
    --staging_location=gs://${BUCKET}/staging \
    --temp_location=gs://${BUCKET}/staging/temp \
    --job_name=gcs-to-gcs-$(date +%Y%m%d%H%M%S)