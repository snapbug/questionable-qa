#!/bin/sh

nvidia-docker build -t snapbug/qqa:nomkl --build-arg lib=nomkl .

nvidia-docker run -it --name nomkl snapbug/qqa:nomkl python main.py model.nomkl --paper-ext-feats --num_threads 1
