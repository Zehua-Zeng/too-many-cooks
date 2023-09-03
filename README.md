# Too Many Cooks: Exploring How Graphical Perception Studies Influence Visualization Recommendations in Draco

## ArXiv

https://arxiv.org/abs/2308.14241

## OSF

https://osf.io/kxd2f/?view_only=ce75083aa2b5455ba18712e345049e54

## Details

### **zeng-battle-dataset**

(Section 3.1) This folder stores the graphical perception results collated by Zeng & Battle.

- **`to_Draco2.py`**: the code for translating Zeng & Battle's dataset into equivalent Draco2 specification. Results store in the **draco2-training-dataset** folder.

### **draco2-asp**

(Section 3.2) This folder contains the Draco2 asp we use for our analysis, including hard constraints, soft constraints, and the recommendation generator, etc. Since Draco2 is still under development, the version we use is https://github.com/cmudig/draco2/tree/023e9e one.

### `draco2-learn-validation.ipynb`

The code for validating that Draco-Learn and Draco2-Learn share similar training and testing scores.

### **draco2-training-dataset**

(Section 3.3.3) This folder stores the ranked visualization pairs provided by 30 graphical perception works. They are in Draco2 format, got translated from the **zeng-battle-dataset** folder.

### **draco2-case-study**

(Section 4) This folder contains the controlled training datasets, codes and results for Draco2 case study.

- **demo-data**: stores the four ranked visualization pairs we use for the case study.
- **`draco2-case-study.ipynb`**: the code for Draco2 case study.

### **graphical-perception-work-analysis**

(Section 5) This folder stores the code for our analysis section.

- **`visualization-space-coverage.ipynb`**: (Section 5.1.2) the code for identifying different visualization spaces with Draco2 soft constriants.
- **visualization-space-coverage.json**: (Section 5.1.2) the coverage result from the visualization space coverage analysis.
- **`baseline-plus-one-train.ipynb`**: (Section 5.2) the code for training the baseline and plus-one models.
- **`schools-of-thought.ipynb`**: (Section 5.2) the code for quantifying schools of thought with shifts in Draco2 soft constraint weights.
- **`unique-influence-from-soft-contraints.ipynb`**: (Section 5.3.1) the code for quantifying unique influence with shifts in Draco2 soft constraint weights.
- **`weight-shifts-recommendations-correlation.ipynb`**: (Section 5.3.2) the code for analyzing whether there is a correlation between weight shifts and recommendation shifts.
- **`visualization-preferences-all-papers-vs-draco-default.png`**: (Supplemental) comparing the visualization preferences between the algorithm learning from all papers' graphical perception knowledge and the Draco default algorithm.
