"""
gcs to gcs dataflow, and how to use secret manager through setup

python3 dataflows/local_to_local.py --runner=DirectRunner  --output=resource/tmp.txt
"""
import argparse
import json
import logging

import apache_beam as beam
from apache_beam.io import ReadFromText, WriteToText
from apache_beam.io import BigQueryDisposition, WriteToBigQuery
from apache_beam.options.pipeline_options import PipelineOptions

# def sample_access_secret_version(param=None):
#     from google.cloud import secretmanager_v1
#     SECRET_ID = "xxx"
#     PROJECT_ID = "xxx"
#     client = secretmanager_v1.SecretManagerServiceClient()
#     request = secretmanager_v1.AccessSecretVersionRequest(
#         name=f"projects/{PROJECT_ID}/secrets/{SECRET_ID}/versions/latest",
#     )
#     response = client.access_secret_version(request=request)
#     return response.payload.data.decode('UTF-8')

class extrat_movie_name(beam.DoFn):
    def __init__(self):
        self.token = None

    def setup(self):
        def sample_access_secret_version(param=None):
            from google.cloud import secretmanager_v1
            SECRET_ID = "xxx"
            PROJECT_ID = "xxxx"
            client = secretmanager_v1.SecretManagerServiceClient()
            request = secretmanager_v1.AccessSecretVersionRequest(
                name=f"projects/{PROJECT_ID}/secrets/{SECRET_ID}/versions/latest",
            )
            response = client.access_secret_version(request=request)
            return response.payload.data.decode('UTF-8')
        self.token = sample_access_secret_version()

    """extract movie name"""
    def process(self, element):
        movie = element['name']
        return [movie+self.token] #movie
    
def run(argv=None):
    """Runs JSON to GCS pipeline.
    Args:
        argv: Pipeline options as a list of arguments.
    """
    parser = argparse.ArgumentParser()
    parser.add_argument(
        '--input',
        dest='input',
        default='gs://temp-movies/source/sample.json',
        help='Input specified as a GCS path containing movies json.')    
    parser.add_argument(
        '--output',
        dest='output',
        default='gs://temp-movies/dest/full-movies.txt')
     
    known_args, pipeline_args = parser.parse_known_args(argv)
    pipeline_options = PipelineOptions(pipeline_args)
    
    with beam.Pipeline(options=pipeline_options) as p:
        (
            p
            | 'Reading movies JSON file' >> ReadFromText(known_args.input)
            | 'Load JSON to Dict' >> beam.Map(json.loads)
            | 'Get movie name' >> beam.ParDo(extrat_movie_name())
            | 'Write to local' >> WriteToText(known_args.output)
        )
if __name__ == "__main__":
    logging.getLogger().setLevel(logging.INFO)
    run()