#!/bin/sh

for v in "0.2.0" "0.1.12" "0.1.11" "0.1.10" "0.1.9"
do
	nvidia-docker build -t snapbug/qqa:pytorch-${v} --build-arg pytorch=${v} .
done

for v in "0.2.0" "0.1.12" "0.1.11" "0.1.10" "0.1.9"
do
	nvidia-docker run -ti --name pytorch-${v} snapbug/qqa:pytorch-${v} python main.py model.pytorch-${v} --paper-ext-feats --num_threads=1
	nvidia-docker logs pytorch-${v} > pytorch-${v}.log
	nvidia-docker cp pytorch-${v}:castorini/castor/sm_cnn/model.pytorch-${v} .
done
