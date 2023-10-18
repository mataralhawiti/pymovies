import argparse
import json
import logging

import apache_beam as beam
from apache_beam.io import ReadFromText, WriteToText
from apache_beam.io import BigQueryDisposition, WriteToBigQuery
from apache_beam.options.pipeline_options import PipelineOptions

from apache_beam.io.gcp.internal.clients import bigquery

table_spec = bigquery.TableReference(
    projectId='golang-389808',
    datasetId='gomovies',
    tableId='dataflow_movies')

table_schema = {
    'fields': [{
        'name': 'movies_names', 'type': 'STRING', 'mode': 'NULLABLE'
    }]
}

class extrat_movie_name(beam.DoFn):
    """extract movie name"""
    def process(self, element):
        movie = element['name']
        return [movie] #movie
    
def run(argv=None):
    """Runs JSON to GCS pipeline.
    Args:
        argv: Pipeline options as a list of arguments.
    """

    parser = argparse.ArgumentParser()
    parser.add_argument(
        '--input',
        dest='input',
        default='/home/matar/seven/dataflow/gcs-to-gcs/sample.json',
        #/home/matar/seven/dataflow/gcs-to-gcs/sample.json
        help='Input specified as a GCS path containing movies json.')    
    # parser.add_argument(
    #     '--output', required=True, help='Output file to write results to.')
     
    known_args, pipeline_args = parser.parse_known_args(argv)
    pipeline_options = PipelineOptions(pipeline_args)
    
    with beam.Pipeline(runner='DirectRunner', options=pipeline_options) as p:
        (
            p
            | 'Reading movies JSON file' >> ReadFromText(known_args.input)
            | 'Load JSON to Dict' >> beam.Map(json.loads)
            | 'Get movie name' >> beam.ParDo(extrat_movie_name())
            #| 'Write to local' >> WriteToText(known_args.output) #'gs://gomovies/df-result/movies/full-movies.txt'
            | "WriteTableWithStorageAPI" >> WriteToBigQuery(
                table_spec,
                schema=table_schema,
                create_disposition=BigQueryDisposition.CREATE_IF_NEEDED,
                method="STREAMING_INSERTS"
            )
        )
if __name__ == "__main__":
    logging.getLogger().setLevel(logging.INFO)
    run()

# python3 gcs-to-gcs.py --output=gs://gomovies/df-result/movies/full-movies.txt
"""
ValueError: Invalid GCS location: None.
Writing to BigQuery with FILE_LOADS method requires a GCS location to be provided to write files to be loaded into BigQuery.
Please provide a GCS bucket through custom_gcs_temp_location in the constructor of WriteToBigQuery or the fallback option --temp_location, 
or pass method="STREAMING_INSERTS" to WriteToBigQuery. [while running 'WriteTableWithStorageAPI/BigQueryBatchFileLoads/GenerateFilePrefix']
"""