#!/usr/bin/env bash

test -d roles/xanmanning.k3s || ansible-galaxy install -r requirements.yml

vagrant up
