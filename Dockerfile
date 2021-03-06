#
# First, get the nvidia image, which has the nvidia cuda drivers etc.
#
FROM nvidia/cuda:8.0-cudnn6-devel-ubuntu14.04 as base

#
# Install miniconda into it
## Copied from continuumio/miniconda:4.3.14
#

# Do this here, because it'll be cached
COPY aquaint+wiki.txt.gz.ndim=50.bin /

RUN echo "13dc26ecb4455cf437e19b6dcf869867 *aquaint+wiki.txt.gz.ndim=50.bin" | md5sum -c - && \
    apt-get update --fix-missing && apt-get install -y wget unzip bzip2 ca-certificates libglib2.0-0 libxext6 libsm6 libxrender1 git mercurial subversion && \
    echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh && \
    wget --quiet https://repo.continuum.io/miniconda/Miniconda3-4.3.14-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    apt-get install -y curl grep sed dpkg && \
    TINI_VERSION=`curl https://github.com/krallin/tini/releases/latest | grep -o "/v.*\"" | sed 's:^..\(.*\).$:\1:'` && \
    curl -L "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini_${TINI_VERSION}.deb" > tini.deb && \
    dpkg -i tini.deb && \
    rm tini.deb

ENV PATH /opt/conda/bin:$PATH

#
# Then install pytorch, version with/without mkl
## ORIGINALLY FROM continuumio/miniconda:4.3.14
#
FROM base as pytorch

ARG lib=mkl
ARG pytorch=0.1.12

RUN apt install -y build-essential=11.6ubuntu6 && \
    apt-get clean && \
    export CMAKE_PREFIX_PATH="$(dirname $(which conda))/../" && \
    conda install -y conda==4.3.25 python==3.6.1 && \
    if [ "${lib}" = "mkl" ]; then \
        conda install -y mkl==2017.0.3 mkl-service==1.1.2; \
    else \
        conda install -y nomkl==1.0; \
    fi && \
    conda install -y numpy==1.13.1 pyyaml==3.12 setuptools==27.2.0 cmake==3.6.3 gcc==4.8.5 cffi==1.10.0 gensim==1.0.1 nltk==3.2.1 scikit-learn==0.18.1 pandas==0.20.3 && \
    wget https://github.com/pytorch/pytorch/archive/v${pytorch}.tar.gz && \
    tar xzf v${pytorch}.tar.gz && \
    cd pytorch-${pytorch} && \
    python setup.py install

ENV OMP_NUM_THREADS=1
ENV MKL_NUM_THREADS=1

#
# And finally the latest verison, see the README for why this is separate
#
FROM pytorch

COPY castor /castorini/castor
RUN git clone https://github.com/castorini/data /castorini/data && \
    git -C /castorini/data reset --hard 6ed4084 && \
    mv /aquaint+wiki.txt.gz.ndim=50.bin /castorini/data/word2vec && \
    cd /castorini/data/TrecQA && \
    python parse.py && \
    python overlap_features.py && \
    python build_vocab.py && \
    cd /castorini/data/WikiQA && \
    unzip WikiQACorpus.zip && \
    python create-train-dev-test-data.py && \
    mv train train-all && \
    mv test raw-test && \
    mv dev raw-dev && \
    cd /castorini/castor/sm_cnn/trec_eval-8.0 && \
    make

WORKDIR /castorini/castor/sm_cnn
