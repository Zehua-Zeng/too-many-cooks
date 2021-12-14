import os
import json
import logging

from numpy.core.fromnumeric import transpose
from data_util import pairs_to_vec, absolute_path, load_data
from draco.spec import Data, Encoding, Field, Query, Task
from sklearn.model_selection import train_test_split
from typing import Dict
from collections import namedtuple
from linear import train_and_plot

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

PosNegExample = namedtuple(
    "PosNeg", ["pair_id", "data", "task", "source", "negative", "positive"]
)
pos_neg_pickle_path = absolute_path("../../__tmp__/pos_neg.pickle")

def load_schemas(path_list):
    raw_data = {}

    for path in path_list:
        path = absolute_path(path)
        with open(path) as f:
            i = 0
            json_data = json.load(f)

            for row in json_data["data"]:
                fields = list(map(Field.from_obj, row["fields"]))
                spec_schema = Data(fields, row.get("num_rows"))
                src = json_data["source"]

                key = f"{src}-{i}"
                raw_data[key] = PosNegExample(
                    key,
                    spec_schema,
                    row.get("task"),
                    src,
                    row["negative"],
                    row["positive"],
                )

                i += 1

    return raw_data

def load_data(
    datatest_size: float = 0.3, random_state=1
):
    """ Returns:
            a tuple containing: train_dev, test.
    """
    data = _get_pos_neg_data()
    return train_test_split(data, test_size=test_size, random_state=random_state)

def get_weights (schema_list):

    neg_pos_specs = load_schemas(schema_list)
    neg_pos_data = pairs_to_vec(list(neg_pos_specs.values()), ('negative', 'positive'))
    neg_pos_data.to_pickle(pos_neg_pickle_path)

    test_size = 0.1
    neg_pos_data.fillna(0, inplace=True)
    train_dev, _ = train_test_split(neg_pos_data, test_size=test_size)

    clf = train_and_plot(train_dev, test_size=test_size)
    features = train_dev.negative.columns

    if len(schema_list) == 1:
        fname = schema_list[0]
        fname = fname.split('/')[-1].split('_')[0]
        print (fname)

        path = os.path.abspath(
            os.path.join(os.path.dirname(__file__), "../../data/training_weights_output/" + fname + ".lp")
        )
    else:
        path = os.path.abspath(
            os.path.join(os.path.dirname(__file__), "../../data/training_weights_output/all.lp")
        )

    with open(path, "w") as f:
        f.write("% Generated with `python draco/learn/linear.py`.\n\n")

        for feature, weight in zip(features, clf.coef_[0]):
            f.write(f"#const {feature}_weight = {int(weight * 1000)}.\n")

    logger.info(f"Wrote model to {path}")



if __name__ == "__main__":

    # """ Generate and store vectors for labeled data in default path. """
    # schema_list = [
    #     "../../data/training_input/Kim2018assessing_Draco_input.json",
    # ]

    # neg_pos_specs = load_schemas(schema_list)
    # neg_pos_data = pairs_to_vec(list(neg_pos_specs.values()), ('negative', 'positive'))
    # neg_pos_data.to_pickle(pos_neg_pickle_path)

    # """generate weights"""
    # test_size = 0.1
    # neg_pos_data.fillna(0, inplace=True)
    # train_dev, _ = train_test_split(neg_pos_data, test_size=test_size)

    # clf = train_and_plot(train_dev, test_size=test_size)
    # features = train_dev.negative.columns

    # path = os.path.abspath(
    #     os.path.join(os.path.dirname(__file__), "../../data/training_weights_output/weights_learned_Kim2018assessing.lp")
    # )

    # with open(path, "w") as f:
    #     f.write("% Generated with `python draco/learn/linear.py`.\n\n")

    #     for feature, weight in zip(features, clf.coef_[0]):
    #         f.write(f"#const {feature}_weight = {int(weight * 1000)}.\n")

    # logger.info(f"Wrote model to {path}")

    training_data_folder = "../../../../too-many-cooks-knowledge-base/"

    for ftd in os.listdir(training_data_folder):
        if ftd.endswith("_Draco_input.json"):
            ftd_short = ftd.split("_")[0]
            
            schema_list = [training_data_folder + ftd]
            
            try:
                get_weights(schema_list)
            except:
                print (ftd_short)
            
            


