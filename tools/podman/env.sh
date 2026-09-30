#!/usr/bin/env zsh

# Silence the ">>>> Executing external compose provider" banner on every
# `podman compose` call (it delegates to the docker-compose plugin).
export PODMAN_COMPOSE_WARNING_LOGS=false
