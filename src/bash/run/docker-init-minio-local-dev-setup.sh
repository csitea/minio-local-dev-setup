#!/bin/bash

set -x

bash /opt/csi/minio-local-dev-setup/run -a do_deploy_start_minio

trap : TERM INT; sleep infinity & wait
