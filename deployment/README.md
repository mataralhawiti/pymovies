## Deployment options

### Run locally - Python app

Install requirements
```shell
python -m pip install -r requirements.txt
```

Start the app
```shell
python app.py
```
<br>

### Run locally - Docker
```shell
docker build --tag pymovies:v1 .
```

```shell
docker run --rm -p 5000:5000 pymovies:v1
```
<br>

### Run on Minikube (Manually)

**First**, in a terminal window  :

```shell
kubectl apply -f .\k8\deployment.yaml
```

```shell
kubectl apply -f .\k8\service.yaml
```

**Then**, in a separate terminal window start minibuke tunnling :

```shell
minikube tunnel
```

The app should be accessable on :

```http://127.0.0.1:5000/```
<br>

### Run it on Minikube (Helm Chart)

```shell
helm install movies .\charts\myimdb
``` 

**Then**, in a separate terminal window start minibuke tunnling :

```shell
minikube tunnel
```

The app should be accessable on :

```http://127.0.0.1:5000/```
<br>
