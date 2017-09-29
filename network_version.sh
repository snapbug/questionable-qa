#!/bin/sh

for SHA in $( git -C ~/castorini/castor/sm_cnn/ log --pretty=%h __init__.py model.py main.py train.py utils.py ) 
do
	nvidia-docker build -t snapbug/qqa:sha-${SHA} --build-arg sha=${SHA} .
done

for SHA in $( git -C ~/castorini/castor/sm_cnn/ log --pretty=%h __init__.py model.py main.py train.py utils.py ) 
do
	# Train the model
	nvidia-docker run -it --name ${SHA} snapbug/qqa:sha-${SHA} python main.py model.sha${SHA} --paper-ext-feats --num_threads=1
	# Get the model out of the container 
	nvidia-docker cp ${SHA}:castorini/castor/sm_cnn/model.sha${SHA} .
	# Get the training log out
	nvidia-docker logs ${SHA} > model.sha${SHA}.log
	# Remove the container
	nvidia-docker rm ${SHA}
done
