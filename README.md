# pymovies
A simple Flask app to pull movies that I rated on IMDB and present them in better view with the ratings, IMDB scraping was done using BeautifulSoup.
The app can be deployed in many ways such as local, local docker, kubernetes, GCP (Cloud Run), Azure.

# Deployment options

## Run locally - Python app
```python -m pip install -r requirements.txt```

```python app.py```

## Run locally - Docker
```docker build --tag gomovies:v1 .```

```python app.py```

## Run on Minikube (Manually)

**First**, in a terminal window  :

``` kubectl apply -f .\k8\deployment.yaml ```

``` kubectl apply -f .\k8\service.yaml ```

**Then**, in a separate terminal window start minibuke tunnling :

``` minikube tunnel ```

The app should be accessable on :

``` http://127.0.0.1:5000/ ``` 


## Run it on Minikube (Helm Chart)

``` helm install movies .\charts\myimdb ``` 

**Then**, in a separate terminal window start minibuke tunnling :

``` minikube tunnel ```

The app should be accessable on :

``` http://127.0.0.1:5000/ ``` 
