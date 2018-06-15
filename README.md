# Questionable Answers

This repository contains everything required to completely replicate the results presented in:

Matt Crane. "Questionable Answers in Question Answering Research: Reproducibility and Variability of Published Results". In: Transactions of the Association for Computational Linguistics 6 (2018), pp. 241–252. url: https://transacl.org/ojs/index.php/tacl/article/view/1299.

## Status

Unfortunately, the upstream repository
[castorini/castor](//github.com/castorini/castor) has diverged due to history
rewriting changes, so the changesets don't match the official current
repository.

Unfortunately this repository was not forked in time to capture the `cf0e269`
SHA from the official repository before that repositories history was
re-written. This means that if building from source, you'll have a _different_
SHA which is used to build this image. The `setup.sh` script will make this
change, the contents of which can be verified against [the official repository
diff](//github.com/castorini/castor/commit/ed4dba249712e8bbaf5ed7c1486dff52b472daf4).

Running `setup.sh build` will build the docker images from the source,
including making the un-captured change above, while `setup.sh pull` will pull
the prebuilt docker images.

## Requirements

#### Running on GPU

`nvidia-docker` is required to run the GPU based experiments, and for these
experiments version 1 was used. This has since been deprecated by nVidia in
favour of version 2. The results _should_ be the same, but for guarantees
[install version 1](//github.com/nvidia/nvidia-docker/wiki/Installation-(version-1.0)).

#### Building images

The embeddings used by the network should be downloaded from [Aliaksei Severyn's shared file
(520MB)](//drive.google.com/folderview?id=0B-yipfgecoSBfkZlY2FFWEpDR3M4Qkw5U055MWJrenE5MTBFVXlpRnd0QjZaMDQxejh1cWs&usp=sharing),
and placed in the working directory for this repository. The docker image
builder will verify checksums to ensure that the same file is used.

#### Pulling images

All the docker images generated are available online to download/run without
having to be built from scratch. These are listed [on Docker hub](//hub.docker.com/r/snapbug/qqa/tags/)

By default the `setup.sh` script if run with will pull _all_ the tagged images,
this can take a substantial amount of disk space, even though they share a lot
of commonality. If you only, for example, want to replicate the math library
experiments, then manually pull the required images. Look at `run.sh` for which
images are required for which experiments.

| Image         | Figure/Table     | Notes                                          |
|---------------|------------------|------------------------------------------------|
| `sha-*`       | Table 4          | See note above regarding `sha-cf0e269`         |
| `pytorch-*`   | Table 5          |                                                |
| `*mkl`        | Table 6          |                                                |
| `sha-cf0e269` | Table 7          |                                                |
| `sha-cf0e269` | Table 8          |                                                |
| `sha-cf0e269` | Figure 2 (left)  | Just the CPU seeds                             |
| `sha-cf0e269` | Figure 2 (right) | Just the GPU seeds                             |
| `sha-cf0e269` | Figure 2         | Both CPU and GPU seeds                         |
|               | Figure 3         | Use the output from the logs of `run.sh seeds` |
|               | Table 9          | Use the output from the logs of `run.sh seeds` |

## Replication

`run.sh` will successfully replicate all the experiments in the paper using
either the built docker images, or pulled docker images from `setup.sh`. It
takes a single argument that specifies which experiments to run.

| Argument  | Figure/Table     | Notes                                          |
|-----------|------------------|------------------------------------------------|
| all       |                  | All of the experiments                         |
| network   | Table 4          |                                                |
| pytorch   | Table 5          |                                                |
| mathlib   | Table 6          |                                                |
| thread    | Table 7          |                                                |
| gpu       | Table 8          |                                                |
| seeds-cpu | Figure 2 (left)  | Just the CPU seeds                             |
| seeds-gpu | Figure 2 (right) | Just the GPU seeds                             |
| seeds     | Figure 2         | Both CPU and GPU seeds                         |
|           | Figure 3         | Use the output from the logs of `run.sh seeds` |
|           | Table 9          | Use the output from the logs of `run.sh seeds` |

**Log** files are generated in the form `qqa.[dataset].log.[experiment]`, at the
end of training the network performs a feed-forward pass of the datasets, which
is where the numbers for the paper are extracted.

**Model** files will be generated in the form:
`qqa.[dataset].model.[experiment]`, to allow for feed-forward verification, or
re-creation of the results without retraining the network. These models, in my
experimentation, are reproducible across different hardware setups, although I
would be interested in hearing of situations where they _aren't_.

## Issues

If you encounter any issues with the scripts etc. in this repository, then
either file an issue on github, or email me.
