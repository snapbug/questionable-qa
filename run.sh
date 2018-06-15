#!/bin/bash

if [ $# -ne 1 ]; then
	echo -e "Usage: $0 <all | network | pytorch | mathlib | thread | gpu | seeds-cpu | seeds-gpu | seeds>"
	echo -e "\tRun the experiment set given in the argument"
	exit
fi

if [[ $1 = "all" || $1 = "network" ]]; then
	for NETWORK_VERSION in $( docker images --filter=reference='snapbug/qqa:sha-*' --format "{{.Repository}}:{{.Tag}}" )
	do
		bn=$( basename ${NETWORK_VERSION} )
		for dataset in "TrecQA" "WikiQA"
		do
			docker run -it --name qqa ${NETWORK_VERSION} sh -c "python main.py qqa.${dataset}.model.${bn} --paper-ext-feats --num_threads=1 --dataset_folder=../../data/${dataset}"
			docker logs qqa > qqa.${dataset}.log.${bn}
			docker cp qqa:/castorini/castor/sm_cnn/qqa.${dataset}.model.${bn}
			docker rm qqa
		done
	done
fi

if [[ $1 = "all" || $1 = "pytorch" ]]; then
	for PYTORCH_VERSION in $( docker images --filter=reference='snapbug/qqa:pytorch-*' --format "{{.Repository}}:{{.Tag}}" )
	do
		bn=$( basename ${PYTORCH_VERSION} )
		for dataset in "TrecQA" "WikiQA"
		do
			docker run -it --name qqa ${PYTORCH_VERSION} sh -c "python main.py qqa.${dataset}.model.${bn} --paper-ext-feats --num_threads=1 --dataset_folder=../../data/${dataset}"
			docker logs qqa > qqa.${dataset}.log.${bn}
			docker cp qqa:/castorini/castor/sm_cnn/qqa.${dataset}.model.${bn}
			docker rm qqa
		done
	done
fi

if [[ $1 = "all" || $1 = "mathlib" ]]; then
	for MATH_LIB in $( docker images --filter=reference='snapbug/qqa:*mkl' --format "{{.Repository}}:{{.Tag}}" )
	do
		bn=$( basename ${MATH_LIB} )
		for dataset in "TrecQA" "WikiQA"
		do
			docker run -it --name qqa ${MATH_LIB} sh -c "python main.py qqa.${dataset}.model.${bn} --paper-ext-feats --num_threads=1 --dataset_folder=../../data/${dataset}"
			docker logs qqa > qqa.${dataset}.log.${bn}
			docker cp qqa:/castorini/castor/sm_cnn/qqa.${dataset}.model.${bn}
			docker rm qqa
		done
	done
fi

if [[ $1 = "all" || $1 = "thread" ]]; then
	for threads in `seq 1 6`
	do
		for dataset in "TrecQA" "WikiQA"
		do
			docker run -it --name qqa snapbug/qqa:sha-cf0e269 sh -c "OMP_NUM_THREADS=${threads} MKL_NUM_THREADS=${threads} python main.py qqa.${dataset}.model.threads-${threads} --paper-ext-feats --num_threads=${threads} --dataset_folder=../../data/${dataset}"
			docker logs qqa > qqa.${dataset}.log.threads-${threads}
			docker cp qqa:/castorini/castor/sm_cnn/qqa.${dataset}.model.threads-${threads} .
			docker rm qqa
		done
	done
fi

if [[ $1 = "all" || $1 = "seeds-cpu" || $1 = "seeds" ]]; then
	RANDOM=1234
	reps=0
	# 200 reps, 2 datasets, 400 repetitions ...
	# because we check whether a seed has been repeated by checking for a log file, which changes name based on the dataset
	while [ ${reps} -lt 400 ]
	do
		seed=$(( RANDOM ))
		for dataset in "TrecQA" "WikiQA"
		do
			if [ ! -f qqa.${dataset}.log.cpu.seed-${seed} ]
			then
				docker run -it --name qqa snapbug/qqa:sha-cf0e269 sh -c "python main.py qqa.${dataset}.model.cpu-seed-${seed} --paper-ext-feats --num_threads=1 --seed ${seed} --dataset_folder=../../data/${dataset}"
				docker logs qqa > qqa.${dataset}.log.cpu-seed-${seed}
				docker cp qqa:castorini/castor/sm_cnn/qqa.${dataset}.model.cpu.seed-${seed} .
				docker rm qqa
				reps=$[$reps + 1]
			fi
		done
	done
fi

GPU_DOCKER=
GPU_RUNTIME=

if [[ $1 = "all" || $1 = "gpu" || $1 = "seeds-gpu" || $1 = "seeds" ]]; then
	if [ $( command -v nvidia-docker ) ]; then
		echo Found \`nvidia-docker\` for GPU experiments.
		GPU_DOCKER=nvidia-docker
	elif [ $( docker run --runtime=nvida hello-world 1>&2 2>/dev/null ) ]; then
		echo Found \`--runtime=nvidia\` option for docker, using this for GPU experiments, but it may not match!
		GPU_DOCKER=docker
		GPU_RUNTIME=--runtime=nvidia
	fi

	if [[ "$GPU_DOCKER" -eq "" && "$GPU_RUNTIME" -eq "" ]]; then
		echo No suitable GPU runtime found, skipping GPU experiments
		exit
	fi
fi

if [[ $1 = "all" || $1 = "gpu" ]]; then
	for cudnn in "" "--nocudnn"
	do
		for dataset in "TrecQA" "WikiQA"
		do
			${GPU_DOCKER} run ${GPU_RUNTIME} -it --name qqa snapbug/qqa:sha-cf0e269 sh -c "python main.py qqa.${dataset}.model.gpu --paper-ext-feats --cuda ${cudnn} --dataset_folder=../../data/${dataset}"
			${GPU_DOCKER} logs ${GPU_RUNTIME} qqa > qqa.${dataset}.log.gpu
			${GPU_DOCKER} cp ${GPU_RUNTIME} qqa:/castorini/castor/sm_cnn/qqa.${dataset}.model.gpu .
			${GPU_DOCKER} rm ${GPU_RUNTIME} qqa
		done
	done
fi

if [[ $1 = "all" || $1 = "seeds-gpu" || $1 = "seeds" ]]; then
	RANDOM=1234
	reps=0
	# 200 reps, 2 datasets, 400 repetitions ...
	# because we check whether a seed has been repeated by checking for a log file, which changes name based on the dataset
	while [ ${reps} -lt 400 ]
	do
		seed=$(( RANDOM ))
		for dataset in "TrecQA" "WikiQA"
		do
			if [ ! -f qqa.${dataset}.log.gpu.seed-${seed} ]
			then
				${GPU_DOCKER} run ${GPU_RUNTIME} -it --name qqa snapbug/qqa:sha-cf0e269 sh -c "python main.py qqa.${dataset}.model.gpu-seed-${seed} --paper-ext-feats --cuda --nocudnn --seed ${seed} --dataset_folder=../../data/${dataset}"
				${GPU_DOCKER} logs ${GPU_RUNTIME} qqa > qqa.${dataset}.log.gpu-seed-${seed}
				${GPU_DOCKER} cp ${GPU_RUNTIME} qqa:castorini/castor/sm_cnn/qqa.${dataset}.model.gpu-seed-${seed} .
				${GPU_DOCKER} rm ${GPU_RUNTIME} qqa
				reps=$[$reps + 1]
			fi
		done
	done
fi
