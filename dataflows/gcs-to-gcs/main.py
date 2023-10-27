"""
# https://www.pythian.com/blog/apache-beam-the-future-of-data-processing

gcs to gcs dataflow, and how to use secret manager through setup

python3 dataflows/gcs_to_gcs.py --runner=DirectRunner  --output=resource/tmp.txt
python3 dataflows/gcs_to_gcs.py --runner=DirectRunner dataflow
"""
import argparse
import json
import logging

import apache_beam as beam
from apache_beam.io import ReadFromText, WriteToText
from apache_beam.io import BigQueryDisposition, WriteToBigQuery
from apache_beam.options.pipeline_options import PipelineOptions

class extrat_movie_name(beam.DoFn):
    def __init__(self):
        self.token = " -token" #None

    # def setup(self):
    #     def sample_access_secret_version(param=None):
    #         from google.cloud import secretmanager_v1
    #         SECRET_ID = "xxx"
    #         PROJECT_ID = "xxxx"
    #         client = secretmanager_v1.SecretManagerServiceClient()
    #         request = secretmanager_v1.AccessSecretVersionRequest(
    #             name=f"projects/{PROJECT_ID}/secrets/{SECRET_ID}/versions/latest",
    #         )
    #         response = client.access_secret_version(request=request)
    #         return response.payload.data.decode('UTF-8')
    #     self.token = sample_access_secret_version()

    """extract movie name"""
    def process(self, element):
        movie = element['name']
        yield movie+self.token
    
def run(argv=None):
    """Runs JSON to GCS pipeline.
    Args:
        argv: Pipeline options as a list of arguments.
    """
    parser = argparse.ArgumentParser()
    parser.add_argument(
        '--input',
        dest='input',
        default='gs://matar-useast1-00111001-dev/source/sample2.json',
        help='Input specified as a GCS path containing movies json.')    
    parser.add_argument(
        '--output',
        dest='output',
        default='gs://matar-useast1-00111001-dev/dest/names')
     
    known_args, pipeline_args = parser.parse_known_args(argv)
    pipeline_options = PipelineOptions(pipeline_args)
    
    with beam.Pipeline(options=pipeline_options) as p:
        data = (
            p
            | 'Reading movies JSON file' >> ReadFromText(known_args.input)
            | 'Load JSON to Dict' >> beam.Map(json.loads)
        )
        movies_count = (
            data
            | 'Get movies count' >> beam.combiners.Count.Globally()
            | 'Write count' >> WriteToText(file_path_prefix='gs://matar-useast1-00111001-dev/dest/count', file_name_suffix='.txt')
        )
        movies_names = (
            data
            | 'Get movie name' >> beam.ParDo(extrat_movie_name())
            | 'Write names' >> WriteToText(file_path_prefix=known_args.output, file_name_suffix='.txt')
        )
if __name__ == "__main__":
    logging.getLogger().setLevel(logging.INFO)
    run()