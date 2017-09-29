#!/bin/bash

cd /castorini/data/TrecQA
python parse.py
python overlap_features.py
python build_vocab.py
python build_qrels.py

cd /castorini/castor/idf_baseline
python qa-data-only-idf.py ../../data/TrecQA TrecQA

../sm_cnn/trec_eval-8.0/trec_eval ../../data/TrecQA/raw-test.qrel TrecQA.raw-test.idfsim
