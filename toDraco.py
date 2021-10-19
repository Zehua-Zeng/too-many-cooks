import json
import re

## global variable
search_num = "\d{1}$"

## helper function:
def encodings_to_vgl (encoding_list):
    vgl_encoding = {}
    for encode in encoding_list:
        channel = encode["channels"][0]
        attr =  encode["attribute-type"]
        if re.search(search_num, attr) is not None:
            attr = attr[0] + attr[-1]
        else:
            attr = attr[0]
        vgl_encoding[channel] = {}
        vgl_encoding[channel]["field"] = attr
        if attr.startswith("q"):
            vgl_encoding[channel]["type"] = "quantitative"
            vgl_encoding[channel]["scale"] = {
                "zero": True
            }
        elif attr.startswith("n"):
            vgl_encoding[channel]["type"] = "nominal"
        elif attr.startswith("o"):
            vgl_encoding[channel]["type"] = "ordinal"
    return vgl_encoding

fr = open('Kim2018assessing.json', 'r')
read_json = json.load(fr)

design_vgl = {}

for design in read_json["Covered Designs"]:
    design_vgl[design] = encodings_to_vgl(read_json["Covered Designs"][design]["layers"][0]["encodings"])

to_draco_data = []

for metric in read_json["Results"]["Experimental"]:
    for task in read_json["Results"]["Experimental"][metric]:
        sig = read_json["Results"]["Experimental"][metric][task]["significance"]
        for pair in sig:
            one_comparison = {}
            pos = pair[0]
            neg = pair[1]
            if pos.startswith("O") or neg.startswith("O"):
                continue
            one_comparison["task"] = task
            one_comparison["positive"] = design_vgl[pos]
            one_comparison["negative"] = design_vgl[neg]
            one_comparison["p-value"] = 0.01
            to_draco_data.append(one_comparison)

with open('Kim2018assessing_generated_Draco_data.json', 'w', encoding="utf-8") as out:
    json.dump(to_draco_data, out, indent = 2, ensure_ascii=False)