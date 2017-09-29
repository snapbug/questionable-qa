#!/bin/bash

# Assumes that versions has been done first to build snapbug/qqa:sha-cf0e269

for t in `seq 2 6`
do
	nvidia-docker run -it --name threads-${t} snapbug/qqa:sha-cf0e269 sh -c "OMP_NUM_THREADS=${t} MKL_NUM_THREADS=${t} python main.py model.threads-${t} --paper-ext-feats --num_threads=${t}"
	nvidia-docker logs threads-${t} > threads.${t}.log
	nvidia-docker cp threads-${t}:/castorini/castor/sm_cnn/model.threads-${t} .
	nvidia-docker rm threads-${t}
done
