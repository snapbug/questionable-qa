#!/bin/sh

for SHA in $( git -C ~/castorini/castor/sm_cnn/ log --pretty=%h __init__.py model.py main.py train.py utils.py ) 
do
	nvidia-docker build -t snapbug/qqa:sha-${SHA} --build-arg sha=${SHA} .
done
