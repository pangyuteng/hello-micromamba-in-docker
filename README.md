# hello-micromamba-in-docker


requiremnt; custom uid:gid with micromamba in docker

```



docker build -t ok .

docker run -it -u 2002:200 -w /opt/workdir -v $PWD:/opt/workdir ok bash


if you need to create new user
"--no-log-init" crucial to avoid docker build hanging for large uid

https://micromamba-docker.readthedocs.io/en/latest/advanced_usage.html#changing-the-user-id-or-name

https://micromamba-docker.readthedocs.io/en/latest/advanced_usage.html#using-a-lockfile

# use of lock file is not enough as pip dependencies are missing
# RUN micromamba env export --name shadow-mode-simplemind --explicit > env.lock
# COPY --chown=$MAMBA_USER:$MAMBA_USER mamba/env.lock /tmp/env.lock
# RUN micromamba install --name base --yes --file /tmp/env.lock \
#     && micromamba clean --all --yes


```