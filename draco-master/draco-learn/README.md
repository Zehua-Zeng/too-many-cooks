# Draco-Learn

[![Build Status](https://travis-ci.com/uwdata/draco-learn.svg?branch=master)](https://travis-ci.com/uwdata/draco-learn)
[![PyPi](https://img.shields.io/pypi/v/malfoy.svg)](https://pypi.org/project/malfoy/)

This repository houses the machine learning tools behind Draco-Learn.

## How to use
* edit the list of path files `schema_list` inside `generate_weights.py`
* run `python malfoy/learn/generate_weights.py`

## learned weights
* [`asp/weights_learned_kim.lp`](https://github.com/JunranY/draco-learn/blob/master/asp/weights_learned_kim.lp): trained with kim2018assessing
* [`asp/weights_learned_original.lp`](https://github.com/JunranY/draco-learn/blob/master/asp/weights_learned_kim.lp): trained with baseline(kim2018, manual, saket2018)
* [`asp/weights_learned.lp`](https://github.com/JunranY/draco-learn/blob/master/asp/weights_learned_kim.lp): trained with baseline and kim2018assessing
