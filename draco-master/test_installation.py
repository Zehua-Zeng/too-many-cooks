from draco.helper import data_to_asp, read_data_to_asp
from draco.js import vl2asp, data2schema

data = [
    {
      "num_rows": 100,
      "significant": "accuracy",
      "fields": [
        {
          "name": "n",
          "type": "string",
          "cardinality": 2
        },
        {
          "name": "q",
          "type": "number",
          "cardinality": 100
        }
      ],
      "task": "value",
      "negative": {
        "mark": "point",
        "encoding": {
          "x": {
            "field": "n1",
            "type": "nominal"
          },
          "y": {
            "field": "q1",
            "type": "quantitative",
            "scale": {"domain": [0,100], "schema": "blues"}
          }
        }
      },
      "positive": {
        "mark": "point",
        "encoding": {
          "x": {
            "field": "n1",
            "type": "nominal"
          },
          "y": {
            "field": "q1",
            "type": "quantitative",
            "scale": {"domain": [0,100], "schema": "viridis"}
          }
        }
      },
      "pvalue": 0.001
    },
  ]

print (data_to_asp(data))

test = {"mark": "bar",
        "encoding": {
            "x": {"type": "ordinal", "field": "n1"},
            "y": {"type": "quantitative", "field": "q1"},
        },}
            

query = vl2asp(test)
print (query)


print(read_data_to_asp('/Users/junranyang/Documents/code/draco/data/cars.csv'))
data = [{'name': 'chevrolet chevelle malibu', 'miles_per_gallon': 18.0, 'cylinders': 8, 'displacement': 307.0, 'horsepower': 130.0, 'weight_in_lbs': 3504, 'acceleration': 12.0, 'year': '1970-01-01', 'origin': 'USA'}, {'name': 'buick skylark 320', 'miles_per_gallon': 15.0, 'cylinders': 8, 'displacement': 350.0, 'horsepower': 165.0, 'weight_in_lbs': 3693, 'acceleration': 11.5, 'year': '1970-01-01', 'origin': 'USA'}, {'name': 'plymouth satellite', 'miles_per_gallon': 18.0, 'cylinders': 8, 'displacement': 318.0, 'horsepower': 150.0, 'weight_in_lbs': 3436, 'acceleration': 11.0, 'year': '1970-01-01', 'origin': 'USA'}, {'name': 'amc rebel sst', 'miles_per_gallon': 16.0, 'cylinders': 8, 'displacement': 304.0, 'horsepower': 150.0, 'weight_in_lbs': 3433, 'acceleration': 12.0, 'year': '1970-01-01', 'origin': 'USA'}, {'name': 'ford torino', 'miles_per_gallon': 17.0, 'cylinders': 8, 'displacement': 302.0, 'horsepower': 140.0, 'weight_in_lbs': 3449, 'acceleration': 10.5, 'year': '1970-01-01', 'origin': 'USA'}, {'name': 'ford galaxie 500', 'miles_per_gallon': 15.0, 'cylinders': 8, 'displacement': 429.0, 'horsepower': 198.0, 'weight_in_lbs': 4341, 'acceleration': 10.0, 'year': '1970-01-01', 'origin': 'USA'}, {'name': 'chevrolet impala', 'miles_per_gallon': 14.0, 'cylinders': 8, 'displacement': 454.0, 'horsepower': 220.0, 'weight_in_lbs': 4354, 'acceleration': 9.0, 'year': '1970-01-01', 'origin': 'USA'}]
print(data2schema(data))

import json
import os

from jsonschema import validate

from draco.run import run
from draco.helper import read_data_to_asp
from draco.js import cql2asp

EXAMPLES_DIR = os.path.join("examples")
json_files = [
            os.path.join(EXAMPLES_DIR, fname)
            for fname in os.listdir(EXAMPLES_DIR)
            if fname.endswith(".json") and not fname.endswith(".vl.json")
        ]

with open("js/node_modules/vega-lite/build/vega-lite-schema.json") as sf:
            schema = json.load(sf)

            for fname in json_files:
                with open(fname, "r") as f:
                    query_spec = json.load(f)

                    data = None
                    if "url" in query_spec["data"]:            

                        data = read_data_to_asp(
                            os.path.join(
                                os.path.dirname(f.name), query_spec["data"]["url"]
                            )
                        )
                    elif "values" in query_spec["data"]:
                        data = read_data_to_asp(query_spec["data"]["values"])
                    else:
                        raise Exception("no data found in spec")
                    # print(data)
                    query = cql2asp(query_spec)
                    print(query, "query")
                    program = query + data
                    result = run(program, silence_warnings=True)
                    print(result.props)
                    # validate(result.as_vl(), schema)