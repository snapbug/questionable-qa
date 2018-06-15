#!/bin/bash

case $1 in
	"build")
		echo "Building docker images from source"
		;;
	"pull")
		echo "Pulling pre-built docker images"
		;;
	*)
		echo "Usage: $0 <build|pull>"
		exit
		;;
esac

case $1 in
	"build")
		# Clone the repository
		git clone https://github.com/snapbug/castor castor

		# Get the old commits
		OLD_COMMITS=$( git -C ./castor/sm_cnn log --pretty=%h __init__.py model.py main.py train.py utils.py )

		# Make the change that was made in `cf0e269`, and then commit it
		sed -i'' -e "s/backend' action/backend', action/" castor/sm_cnn/main.py
		git -C castor commit -m "Typo fix" sm_cnn/main.py
		NSHA=$(git -C castor rev-parse --short HEAD)

		# Table 4 -- network model versions
		docker build -t snapbug/qqa:sha-cf0e269 .
		for SHA in ${OLD_COMMITS}
		do
			docker build -t snapbug/qqa:sha-${SHA} --build-arg sha=${SHA} -f Dockerfile.change-sha .
		done

		# Table 5 -- pytorch framework versions
		for v in "0.2.0" "0.1.11" "0.1.10" "0.1.9"
		do
			docker build -t snapbug/qqa:pytorch-${v} --build-arg pytorch=${v} .
		done
		docker tag snapbug/qqa:sha-cf0e269 snapbug/qqa:pytorch-0.1.12

		# Table 6 -- math library versions
		docker build -t snapbug/qqa:nomkl --build-arg lib=nomkl .
		docker tag snapbug/qqa:sha-cf0e269 snapbug/qqa:mkl

		echo ${NSHA} was used instead to generate cf0e269, see READEME for reasons
		# The other results -- threads, gpu, seeds -- are all runtime options
		;;
	"pull")
		docker pull --all-tags snapbug/qqa
		;;
esac
