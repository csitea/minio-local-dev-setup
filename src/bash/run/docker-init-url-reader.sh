#!/bin/bash

set -x

test -z ${PRODUCT:-} && PRODUCT=url-reader

venv_path="$PRODUCT_DIR/src/python/url-reader/.venv"
home_venv_path="$HOME_PRODUCT_DIR/src/python/url-reader/.venv"
venv_path="$PRODUCT_DIR/src/python/url-reader/.venv"


test -d $venv_path && sudo rm -r $venv_path
cp -vr $home_venv_path $venv_path

perl -pi -e "s|/home/$APPUSR||g" $venv_path/bin/activate


echo "source $PRODUCT_DIR/src/python/url-reader/.venv/bin/activate" >> ~/.bashrc
trap : TERM INT; sleep infinity & wait
