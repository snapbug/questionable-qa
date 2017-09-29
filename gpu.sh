#!/bin/bash

# Assumes that versions has been done first to build snapbug/qqa:sha-cf0e269

nvidia-docker run -itd --name gpu snapbug/qqa:sha-cf0e269 python main.py model.gpu --paper-ext-feats --num_threads=1 --cuda
nvidia-docker run -itd --name gpu.nocudnn snapbug/qqa:sha-cf0e269 python main.py model.gpu.nocudnn --paper-ext-feats --num_threads=1 --cuda --nocudnn

nvidia-docker wait gpu gpu.nocudnn

nvidia-docker logs gpu > gpu.log
nvidia-docker cp gpu:/castorini/castor/sm_cnn/model.gpu .
nvidia-docker rm gpu

nvidia-docker logs gpu.nocudnn > gpu.nocudnn.log
nvidia-docker cp gpu.nocudnn:/castorini/castor/sm_cnn/model.gpu.nocudnn .
nvidia-docker rm gpu.nocudnn
