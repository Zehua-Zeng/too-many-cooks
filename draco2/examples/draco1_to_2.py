from hashlib import new
import json

f_saket = open("kim2018_draco1.json")
saket_data = json.load(f_saket)

new_data = []

for pair in saket_data["data"]:
    new_schema = {}

    new_schema["data"] = []
    # number of rows
    if "num_rows" in pair:
        new_schema["data"].append("attribute(number_rows,root,"+ str(pair["num_rows"]) + ")")

    # fields
    for field in pair["fields"]:
        new_schema["data"].append("entity(field,root," + field["name"] + ").")
        for attr in field:
            if attr == "cardinality":
                new_schema["data"].append("attribute(field,unqiue)," + field["name"] + "," + str(field[attr]) + ").")
            if attr == "interesting":
                new_schema["data"].append("attribute(field,interesting)," + field["name"] + ",true).")
            else:
                new_schema["data"].append("attribute(field," + attr + ")," + field["name"] + "," + str(field[attr]) + ").")
    
    # task
    new_schema["task"] = ""
    if "task" in pair:
        new_schema["task"] = pair["task"]
    
    # significant
    new_schema["significant"] = ""
    if "significant" in pair:
        new_schema["significant"] = pair["significant"]
    
    # pvalue
    new_schema["pvalue"] = ""
    if "pvalue" in pair:
        new_schema["pvalue"] = pair["pvalue"]
    
    # visualization
    viz = ["positive", "negative"]

    for vis in viz:
        new_schema[vis] = []
        new_schema[vis].append("entity(view,root,v).")

        # mark
        new_schema[vis].append("entity(mark,v,m).")
        new_schema[vis].append("attribute((mark,type),m," + pair[vis]["mark"] + ").")

        # encodings
        no = 1
        for channel in pair[vis]["encoding"]:
            encoding_id = "e" + str(no)
            new_schema[vis].append("entity(encoding,m," + encoding_id + ")")
            new_schema[vis].append("attribute((encoding,channel)," + encoding_id + "," + channel + ").")
            new_schema[vis].append("attribute((encoding,field)," + encoding_id + "," + pair[vis]["encoding"][channel]["field"] + ").")

            if "aggregate" in pair[vis]["encoding"][channel]:
                new_schema[vis].append("attribute((encoding,aggregate)," + encoding_id + "," + pair[vis]["encoding"][channel]["aggregate"] + ").")

            # scale
            scale_id = "s" + str(no)
            new_schema[vis].append("entity(scale,v," + scale_id + ")")
            new_schema[vis].append("attribute((scale,channel)," + scale_id + "," + channel + ").")
            if pair[vis]["encoding"][channel]["type"] == "quantitative":
                new_schema[vis].append("attribute((scale,type)," + scale_id + ",linear).")
            if pair[vis]["encoding"][channel]["type"] == "ordinal":
                new_schema[vis].append("attribute((scale,type)," + scale_id + ",ordinal).")
            if channel != "color" and pair[vis]["encoding"][channel]["type"] == "nominal":
                new_schema[vis].append("attribute((scale,type)," + scale_id + ",ordinal).")
            if channel == "color" and pair[vis]["encoding"][channel]["type"] == "nominal":
                new_schema[vis].append("attribute((scale,type)," + scale_id + ",categorical).")
            
            if "scale" in pair[vis]["encoding"][channel]:
                new_schema[vis].append("attribute((scale,zero)," + scale_id + ",true).")
            
            no += 1
    
    new_data.append(new_schema)

# list to str
# lists = ["data", "negative", "positive"]
# for data_col in new_data:
#     for li in lists:
#         data_col[li] = "\n".join(data_col[li])

with open('kim2018_draco2.json', 'w') as out:
    json.dump(new_data, out, indent = 2)