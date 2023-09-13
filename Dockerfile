ARG python=python:3.10-slim-buster

# First stage
FROM ${python}

LABEL Name=pymovies

# Keeps Python from generating .pyc files in the container
ENV PYTHONDONTWRITEBYTECODE 1

# Turns off buffering for easier container logging
ENV PYTHONUNBUFFERED 1

# Install pip requirements
COPY requirements.txt .
RUN python -m pip install -r requirements.txt

WORKDIR /app
COPY . /app

# Switching to a non-root user
RUN useradd appuser && chown -R appuser /app
USER appuser

# Run
#CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]
CMD exec gunicorn --bind 0.0.0.0:5000 --workers 1 --threads 8 --timeout 0 app:app
