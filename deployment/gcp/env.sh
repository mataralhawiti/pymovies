export GCP_PROJECT=<PROJECT_ID>
export AUTH_TOKEN=$(gcloud auth print-access-token)
export INSTANCE_ID=your-instance-name
export REGION=us-central1
export CDAP_ENDPOINT=$(gcloud beta data-fusion instances describe \
    --location=$REGION \
    --format="value(apiEndpoint)" \
  ${INSTANCE_ID})

#export GCP_PROJECT_NUMBER="$(gcloud projects describe $(gcloud config get-value project) --format='value(projectNumber)')"

#export REPOSITORY="samples"

#printenv | grep GCP_PROJECT_ID