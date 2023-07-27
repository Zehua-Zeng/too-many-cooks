import json
import re
import os

task_dict = {
    "retrieve-value": "value",
    "filter": "value",
    "sort": "value",
    "cluster": "value",
    "correlate": "value",
    "aggregate": "summary",
    "find-extremum": "summary",
    "determine-range": "summary",
    "characterize-distribution": "summary",
    "find-anomalies": "summary",
    "overall": "summary"
}


def get_fields(pos, task):
    data = []
    data.append("attribute(task,root," + task + ").")

    if "num_rows" in fdata["Designs"][pos]:
        data.append("attribute(number_rows,root," + str(fdata["Designs"][pos]["num_rows"]) + ").")

    fields = fdata["Designs"][pos]["fields"]
    for field in fields:
        data.append("entity(field,root," + field["name"] + ").")
        for attr in field:
            if attr == "unique":
                data.append("attribute((field,unqiue)," + field["name"] + "," + str(field[attr]) + ").")
            elif attr == "interesting":
                data.append("attribute((field,interesting)," + field["name"] + ",true).")
            elif attr == "entropy":
                data.append("attribute((field,entropy)," + field["name"] + "," + str(field[attr]) + ").")
            else:
                data.append("attribute((field," + attr + ")," + field["name"] + "," + str(field[attr]) + ").")
    return data


def get_view(design):

    draco_des = []

    draco_des.append("entity(view,root,v).")

    # coordinates
    draco_des.append("attribute((view,coordinates),v," + design["coordinates"] + ").")
    
    # mark
    draco_des.append("entity(mark,v,m).")
    if "mark" in design:
        draco_des.append("attribute((mark,type),m," + design["mark"] + ").")

    # encodings
    no = 1
    for channel in design["encoding"]:

        if re.search(r'\d+$', channel):
            channel = channel[:-1]

        # facet
        if channel == "row" or channel == "col":
            draco_des.append("entity(facet,v,f).")
            draco_des.append("attribute((facet,channel),f," + channel + ").")
            draco_des.append("attribute((facet,field),f," + design["encoding"][channel]["field"] + ").")
            continue

        # normal encoding
        encoding_id = "e" + str(no)
        draco_des.append("entity(encoding,m," + encoding_id + ").")
        draco_des.append("attribute((encoding,channel)," + encoding_id + "," + channel + ").")
        if "field" in design["encoding"][channel]:
            draco_des.append("attribute((encoding,field)," + encoding_id + "," + design["encoding"][channel]["field"] + ").")

        # aggregate
        if "aggregate" in design["encoding"][channel]:
            draco_des.append("attribute((encoding,aggregate)," + encoding_id + "," + design["encoding"][channel]["aggregate"] + ").")
        
        # binning
        if "binning" in design["encoding"][channel]:
            draco_des.append("attribute((encoding,binning)," + encoding_id + "," + design["encoding"][channel]["binning"] + ").")
        
        # stack
        if "stack" in design["encoding"][channel]:
            draco_des.append("attribute((encoding,stack)," + encoding_id + "," + design["encoding"][channel]["stack"] + ").")

        # scale
        scale_id = "s" + str(no)
        draco_des.append("entity(scale,v," + scale_id + ").")
        draco_des.append("attribute((scale,channel)," + scale_id + "," + channel + ").")
        if design["encoding"][channel]["type"] == "quantitative":
            draco_des.append("attribute((scale,type)," + scale_id + ",linear).")
        elif design["encoding"][channel]["type"] == "log":
            draco_des.append("attribute((scale,type)," + scale_id + ",log).")
        if design["encoding"][channel]["type"] == "ordinal":
            draco_des.append("attribute((scale,type)," + scale_id + ",ordinal).")
        if channel != "color" and design["encoding"][channel]["type"] == "nominal":
            draco_des.append("attribute((scale,type)," + scale_id + ",ordinal).")
        if channel == "color" and design["encoding"][channel]["type"] == "nominal":
            draco_des.append("attribute((scale,type)," + scale_id + ",categorical).")
        
        if "scale" in design["encoding"][channel]:
            draco_des.append("attribute((scale,zero)," + scale_id + ",true).")
        
        no += 1

    return draco_des


fdata = {}

json_files = [pos_json for pos_json in os.listdir('./') if pos_json.endswith('.json')]

for json_file in json_files:

    print (json_file)
    fr = open(json_file, 'r')
    fdata = json.load(fr)
    
    new_data = []
    task_pos_neg = []

    for metric in fdata["Results"]["Experimental"]:
        for task in fdata["Results"]["Experimental"][metric]:
            sig = fdata["Results"]["Experimental"][metric][task]["significance"]
            for pair in sig:
                comp = {}
                pos = pair[0]
                neg = pair[1]

                if pos not in fdata["Designs"] or neg not in fdata["Designs"]:
                    continue
                
                taskdict = task
                if re.search(r'\d+$', task):
                    taskdict = task[:-2]
                
                ftask = task_dict[taskdict]

                if ftask + pos + neg in task_pos_neg:
                    print ("repeat: " + ftask + pos + neg)
                    continue
                else:
                    task_pos_neg.append(ftask + pos + neg)
                    print ("new: " + ftask + pos + neg)

                comp["task"] = ftask
                comp["positive"] = get_fields(pos, ftask) + get_view(fdata["Designs"][pos]["design"])
                comp["negative"] = get_fields(neg, ftask) + get_view(fdata["Designs"][neg]["design"])
                new_data.append(comp)

    if json_file.split('_')[1].startswith("E"):
        output_file = json_file.split('_')[0] + '(E).json'
    else:
        output_file = json_file.split('_')[0] + '(T).json'
    with open('../draco2-training-datasets/' + output_file, 'w') as out:
        json.dump(new_data, out, indent = 2)