#!/bin/bash

RANDOM=1234

reps=0
while [ ${reps} -lt 200 ]
do
	seed=$(( RANDOM ))

	if [ ! -f model.cpu.seed.${seed}.log ]
	then
		echo ${seed} runs

		nvidia-docker run -itd --name cpu-${seed} snapbug/qqa:pytorch-0.1.12 python main.py model.cpu.seed.${seed} --paper-ext-feats --num_threads=1 --seed ${seed}
		nvidia-docker run -itd --name gpu-${seed} snapbug/qqa:pytorch-0.1.12 python main.py model.gpu.seed.${seed} --paper-ext-feats --num_threads=1 --seed ${seed} --cuda --nocudnn

		# Wait for the containers to finish
		nvidia-docker wait cpu-${seed} gpu-${seed}

		# Get the model out of the container 
		nvidia-docker cp cpu-${seed}:castorini/castor/sm_cnn/model.cpu.seed.${seed} .
		nvidia-docker cp gpu-${seed}:castorini/castor/sm_cnn/model.gpu.seed.${seed} .

		# Get the training log out
		nvidia-docker logs cpu-${seed} > model.cpu.seed.${seed}.log
		nvidia-docker logs gpu-${seed} > model.gpu.seed.${seed}.log

		# Remove the container
		nvidia-docker rm cpu-${seed} gpu-${seed}
		reps=$[$reps + 1]
	else
		echo Skipping ${seed} because it exists
	fi
	echo Done ${reps} of 200
done
