# https://github.com/GoogleCloudPlatform/cloud-run-microservice-template-python

# set env variables
export SERVICE_NAME=pymovies
export GCP_PROJECT_ID="$(gcloud config get-value project)" #printenv | grep GCP_PROJECT_ID
#export GCP_PROJECT_NUMBER="$(gcloud projects describe $(gcloud config get-value project) --format='value(projectNumber)')"
export REGION=us-central1
#export REPOSITORY="samples"





##### Option 1 :
# Submit a build using Google Cloud Build
gcloud builds submit --region=${REGION} --tag gcr.io/${GCP_PROJECT_ID}/${SERVICE_NAME}

# Deploy to Cloud Run
gcloud run deploy ${SERVICE_NAME} \
    --image gcr.io/${GCP_PROJECT_ID}/${SERVICE_NAME} \
    --description="Flasks app that shows my IMDB movies rating" \
    --region=${REGION} \
    #--allow-unauthenticated

# unauthenticated invocations - public
# gcloud run deploy [SERVICE_NAME] ... --allow-unauthenticated
gcloud run services add-iam-policy-binding ${SERVICE_NAME} \
    --member="allUsers" \
    --region=${REGION} \
    --role="roles/run.invoker"

