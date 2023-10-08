# https://github.com/GoogleCloudPlatform/cloud-run-microservice-template-python

# Set env variables
export SERVICE_NAME=pymovies
export GCP_PROJECT_ID="$(gcloud config get-value project)"
export REGION=us-central1

"""
Cloud Run service pymovies in us-central1 is using the default Compute Engine service account. By default, this service account has broad IAM permissions.
To increase the security of this Cloud Run service, create a dedicated service account with minimal permissions and deploy a new revision using it.
pymovies-838@golang-389808.iam.gserviceaccount.com
"""

# Build & Deploy
## Submit a build using Google Cloud Build
gcloud builds submit --region=${REGION} --tag gcr.io/${GCP_PROJECT_ID}/${SERVICE_NAME}

## Deploy to Cloud Run
gcloud run deploy ${SERVICE_NAME} \
    --image gcr.io/${GCP_PROJECT_ID}/${SERVICE_NAME} \
    --description="Flasks app that shows my IMDB movies rating" \
    --region=${REGION} \
    #--allow-unauthenticated

## allow unauthenticated invocations - public
gcloud run services add-iam-policy-binding ${SERVICE_NAME} \
    --member="allUsers" \
    --region=${REGION} \
    --role="roles/run.invoker"

