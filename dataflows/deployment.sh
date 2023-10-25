# Set envs - 9
export GCP_PROJECT="$(gcloud config get-value project)" \
export REGION=us-east1
export _REGION=useast1
export ENV=dev

# GCS buckets

## - create
gcloud storage buckets create gs://temp-movies-${_REGION}-00111001-${ENV}  \
--project=${GCP_PROJECT}  \
--default-storage-class=STANDARD \
--location=${REGION} \
--uniform-bucket-level-access \
--no-public-access-prevention


gcloud storage buckets create gs://temp-bucket-${_REGION}-00111001-${ENV}  \
--project=${GCP_PROJECT}  \
--default-storage-class=STANDARD \
--location=${REGION} \
--uniform-bucket-level-access \
--no-public-access-prevention

gcloud storage buckets create gs://temp-stage-${_REGION}-00111001-${ENV}  \
--project=${GCP_PROJECT}  \
--default-storage-class=STANDARD \
--location=${REGION} \
--uniform-bucket-level-access \
--no-public-access-prevention


## upload

### single file
gcloud storage cp resource/sample2.json gs://temp-movies-${_REGION}-00111001-${ENV}/source/sample2.json

### entire dir
gcloud storage cp -r resource/movies gs://temp-movies-${_REGION}-00111001-${ENV}/source/movies


# enable dataflow API
gcloud services enable dataflow

# Fix stage location
python3 dataflows/gcs_to_gcs_v1.py \
    --region=${REGION} \
    --runner=DataflowRunner \
    --project=${GCP_PROJECT} \
    --job_name=gcs-to-gcs-$(date +%Y%m%d%H%M%S) \
    --temp_location=gs://temp-movies-useast1-00111001-dev