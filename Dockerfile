# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
ARG BASE_CONTAINER=jupyter/minimal-notebook
FROM $BASE_CONTAINER

LABEL maintainer="Jupyter Project <jupyter@googlegroups.com>"

USER root

# Install all OS dependencies for fully functional notebook server
RUN apt-get update && apt-get install -yq --no-install-recommends \
    build-essential \
    git \
    nano \
    && rm -rf /var/lib/apt/lists/*

# Remove stable version of JupyterLab intalled in base notebook Dockerfile
RUN conda remove --quiet --yes \
    'jupyterlab' && \
    conda clean -tipsy && \
    npm cache clean --force && \
    rm -rf $CONDA_DIR/share/jupyter/lab/staging && \
    rm -rf /home/$NB_USER/.cache/yarn && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

# Install jupyterlab + phosphor from source
# The particular commits used below were verified to work on 3/32/2019.
RUN cd /tmp && \
    git clone https://github.com/jupyterlab/jupyterlab_server.git && \
    cd jupyterlab_server && \
    git checkout 346c7d0 && \
    yes | pip install --quiet --no-cache-dir -e . && \
    cd /tmp && \
    git clone https://github.com/vidartf/phosphor.git && \
    cd phosphor/ && \
    git checkout feature-tables3-extras && \
    git checkout bd246d8 && \
    npm install --only=dev typescript@latest && \
    npm install --unsafe-perm && \
    npm run build --unsafe-perm && \
    cd packages/collections && \
    npm link && \
    cd ../algorithm && \
    npm link && \
    cd ../coreutils && \
    npm link && \
    cd /tmp && \
    git clone https://github.com/vidartf/jupyterlab.git && \
    cd jupyterlab/ && \
    git checkout rtc && \
    git checkout 6722a28 && \
    yes | pip install --quiet --no-cache-dir -e . && \
    jlpm install && \
    npm link @phosphor/collections && \
    npm link @phosphor/algorithm && \
    npm link @phosphor/coreutils && \
    jlpm run build && \
    cd && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

ADD handler.py /tmp/jupyterlab/jupyterlab/datastore/handler.py

USER $NB_UID