# 
# based on "Adding micromamba to an existing Docker image"
# https://micromamba-docker.readthedocs.io/en/latest/advanced_usage.html#adding-micromamba-to-an-existing-docker-image
# 

FROM mambaorg/micromamba:2.6.2 AS micromamba

FROM python:3.12-bullseye AS base

USER root

RUN apt-get update && apt-get install git vim jq curl procps -yq

ARG MAMBA_USER=newuser
ARG MAMBA_USER_ID=2002
ARG MAMBA_USER_GID=2002
ENV MAMBA_USER=$MAMBA_USER
ENV MAMBA_ROOT_PREFIX="/opt/conda"
ENV MAMBA_EXE="/bin/micromamba"

COPY --from=micromamba "$MAMBA_EXE" "$MAMBA_EXE"
COPY --from=micromamba /usr/local/bin/_activate_current_env.sh /usr/local/bin/_activate_current_env.sh
COPY --from=micromamba /usr/local/bin/_dockerfile_shell.sh /usr/local/bin/_dockerfile_shell.sh
COPY --from=micromamba /usr/local/bin/_entrypoint.sh /usr/local/bin/_entrypoint.sh
COPY --from=micromamba /usr/local/bin/_dockerfile_initialize_user_accounts.sh /usr/local/bin/_dockerfile_initialize_user_accounts.sh
COPY --from=micromamba /usr/local/bin/_dockerfile_setup_root_prefix.sh /usr/local/bin/_dockerfile_setup_root_prefix.sh

RUN /usr/local/bin/_dockerfile_initialize_user_accounts.sh && \
    /usr/local/bin/_dockerfile_setup_root_prefix.sh

USER $MAMBA_USER

SHELL ["/usr/local/bin/_dockerfile_shell.sh"]

ENTRYPOINT ["/usr/local/bin/_entrypoint.sh"]

WORKDIR /opt

COPY --chown=$MAMBA_USER env.lock /tmp/env.lock 
RUN micromamba create --name shadow --yes --file /tmp/env.lock && \
    micromamba clean --all --yes

COPY --chown=$MAMBA_USER requirements.txt /tmp/requirements.txt
RUN pip install -r /tmp/requirements.txt

# # hack since downstream simplemind wanted different environment names.
RUN ln -s /opt/conda/envs/shadow /opt/conda/envs/nnunet
RUN ln -s /opt/conda/envs/shadow /opt/conda/envs/totalseg

USER $MAMBA_USER
ENV ENV_NAME=shadow