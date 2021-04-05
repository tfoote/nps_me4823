#!/bin/bash

# This is a quick script to be able to reproduce the image with expected rocker overlays.

# build the local env
docker build . -t test_novnc


# setup a virtual env
mkdir -p /tmp/test_novnc_venv
python3 -m venv /tmp/test_novnc_venv
. /tmp/test_novnc_venv/bin/activate
pip install -U git+https://github.com/osrf/rocker.git@cuda
pip install -U git+https://github.com/tfoote/novnc-rocker.git@main

# run the environment that was build
rocker --cuda --nvidia --novnc --turbovnc --user --user-override-name=developer test_novnc