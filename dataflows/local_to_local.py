"""
python3 dataflows/local_to_local.py --runner=DirectRunner  --output=resource/tmp.txt
"""

import argparse
import json
import logging

import apache_beam as beam
from apache_beam.io import ReadFromText, WriteToText
from apache_beam.options.pipeline_options import PipelineOptions

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
        default='resource/sample2.json',
        help='Input specified local path')
    parser.add_argument(
        '--output', required=True, help='Output file to write results to.')
     
    known_args, pipeline_args = parser.parse_known_args(argv)
    pipeline_options = PipelineOptions(pipeline_args)
    
    with beam.Pipeline(runner='DirectRunner', options=pipeline_options) as p:
        (
            p
            | 'Reading movies JSON file' >> ReadFromText(known_args.input)
            | 'Load JSON to Dict' >> beam.Map(json.loads)
            # | 'Get length' >> beam.FlatMap(lambda movies: [len(movies)])
            # | 'Get movie name' >> beam.ParDo(extrat_movie_name())
            | 'extrat movie name' >> beam.FlatMap(lambda movies: [movies['name']])
            | 'Write to local' >> WriteToText(known_args.output)
        )
if __name__ == "__main__":
    logging.getLogger().setLevel(logging.INFO)
    run()