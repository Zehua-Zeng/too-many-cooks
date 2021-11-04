import json
from os import read

fr = open('./are-we-there-yet-new-schema/Kim2018assessing.json', 'r')
read_json = json.load(fr)

## helper functions:
def if_two_fields_equal (f1, f2):
    equal = True
    for ele in f1:
        if ele not in f2:
            equal = False
    for ele in f2:
        if ele not in f1:
            equal = False
    
    return equal

to_draco_data = []

for type in read_json["Results"]:
    for metric in read_json["Results"][type]:
        for task in read_json["Results"][type][metric]:
            sig = read_json["Results"][type][metric][task]["significance"]
            pvalue = read_json["Results"][type][metric][task]["pvalue"]
            for pair in sig:
                one_comparison = {}
                pos = pair[0]
                neg = pair[1]
                if pos.startswith("O") or neg.startswith("O"):
                    continue
                if not if_two_fields_equal(read_json["Covered Designs"][pos]["fields"], read_json["Covered Designs"][neg]["fields"]):
                    print ("not same fields: " + pos + ", " + neg)
                    continue
                one_comparison["fields"] = read_json["Covered Designs"][pos]["fields"]
                one_comparison["task"] = task
                one_comparison["metric"] = metric
                one_comparison["positive"] = read_json["Covered Designs"][pos]["design"]
                one_comparison["negative"] = read_json["Covered Designs"][neg]["design"]
                one_comparison["p-value"] = pvalue
                to_draco_data.append(one_comparison)

with open('./too-many-cooks-knowledge-base/Kim2018assessing_Draco_input.json', 'w', encoding="utf-8") as out:
    json.dump(to_draco_data, out, indent = 2, ensure_ascii=False)

