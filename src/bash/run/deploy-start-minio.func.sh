#!/bin/bash

do_deploy_start_minio(){

  set -eu -o pipefail # fail on error , debug all lines

 	export minio_data_dir='/tmp/minio-data'

 	# set credentials for the server
 	export MINIO_ACCESS_KEY='N9Z4W68XW0YM7P9MF6WG'
 	export MINIO_SECRET_KEY='R2g5sRfT1xou2xfaMoq+pQrLLIB8+erOVRhtNg2F'
 	export MINIO_REGION="local_region"

 	echo MINIO_ACCESS_KEY: $MINIO_ACCESS_KEY
 	echo MINIO_SECRET_KEY: $MINIO_SECRET_KEY
 	echo MINIO_REGION: $MINIO_REGION

	mkdir -p ~/etc/ ; cat << "EOF_02" > ~/etc/openssl.conf
	[req]
	distinguished_name = req_localhost
	x509_extensions = v3_req
	prompt = no

	[req_localhost]
	C = FI
	ST = UU
	L = Helsinki
	O = SE
	OU = hackers_depts
	CN = localhost

	[v3_req]
	subjectAltName = @alt_names

	[alt_names]
	IP.1 = 127.0.0.1
EOF_02

	test $(pgrep minio|wc -l) -gt 0 && kill -9 $(pgrep minio) # kill if running

	mkdir -p ~/.minio/certs/ ;
	test -f ~/.minio/certs/private.key && rm -v ~/.minio/certs/private.key
	openssl genrsa -out ~/.minio/certs/private.key 2048

	test -f ~/.minio/certs/public.crt && rm -v ~/.minio/certs/public.crt
	openssl req -x509 -nodes -days 730 -newkey rsa:2048 -keyout ~/.minio/certs/private.key \
		 -out ~/.minio/certs/public.crt -config ~/etc/openssl.conf

	/usr/local/bin/minio server "$minio_data_dir" 2>&1 &  # and start the server

	export CONFIG_S3_BUCKET_NAME='ava-local-bucket'
	export CONFIG_S3_ENDPOINT='https://127.0.0.1:9000'
	export CONFIG_S3_ACCESS_KEY=$MINIO_ACCESS_KEY
	export CONFIG_S3_SECRET_KEY=$MINIO_SECRET_KEY
	export CONFIG_S3_REGION=$MINIO_REGION
	export CONFIG_S3_DISABLE_SSL_CHECK='true'

	echo CONFIG_S3_BUCKET_NAME: $CONFIG_S3_BUCKET_NAME
	echo CONFIG_S3_ENDPOINT: $CONFIG_S3_ENDPOINT
	echo CONFIG_S3_ACCESS_KEY: $CONFIG_S3_ACCESS_KEY
	echo CONFIG_S3_SECRET_KEY: $CONFIG_S3_SECRET_KEY
	echo CONFIG_S3_REGION: $CONFIG_S3_REGION
	echo CONFIG_S3_DISABLE_SSL_CHECK: $CONFIG_S3_DISABLE_SSL_CHECK

 	export MINIO_HOST_ALIAS='minio_host_alias'
	# register the host alias
	/usr/local/bin/mc config host add $MINIO_HOST_ALIAS "$CONFIG_S3_ENDPOINT" "$CONFIG_S3_ACCESS_KEY" \
		"$CONFIG_S3_SECRET_KEY" --api S3v4

	# create a bucket
	/usr/local/bin/mc --insecure mb --region "$MINIO_REGION" "$MINIO_HOST_ALIAS/$CONFIG_S3_BUCKET_NAME"

	# configure the policies on the bucket
	/usr/local/bin/mc --insecure policy upload "$MINIO_HOST_ALIAS/$CONFIG_S3_BUCKET_NAME"
	/usr/local/bin/mc --insecure policy download "$MINIO_HOST_ALIAS/$CONFIG_S3_BUCKET_NAME"
	/usr/local/bin/mc --insecure policy public "$MINIO_HOST_ALIAS/$CONFIG_S3_BUCKET_NAME"
	/usr/local/bin/mc --insecure policy list "$MINIO_HOST_ALIAS/$CONFIG_S3_BUCKET_NAME"

	mkdir -p ~/.aws/s3cmd/ ; cat << EOF_03 > ~/.aws/s3cmd/minio_local.s3cfg
		host_base = 127.0.0.1:9000
		host_bucket = local-bucket
		bucket_location = local_region
		use_https = True
		access_key =  N9Z4W68XW0YM7P9MF6WG
		secret_key = R2g5sRfT1xou2xfaMoq+pQrLLIB8+erOVRhtNg2F
		signature_v2 = False
EOF_03

	# ls the buckets in the host alias
	/usr/local/bin/mc --insecure ls $MINIO_HOST_ALIAS

	# copy the resource file
	/usr/local/bin/mc --insecure cp -r `pwd` $MINIO_HOST_ALIAS/$CONFIG_S3_BUCKET_NAME

	# and verify it is there
  # /usr/local/bin/mc --insecure stat $MINIO_HOST_ALIAS/$(basename `pwd`)
  /usr/local/bin/mc --insecure ls -r $MINIO_HOST_ALIAS


	# run those manually
	test $(which s3cmd|wc -l) -gt 0 && \
	   s3cmd ls --no-check-certificate -r -c ~/.aws/s3cmd/minio_local.s3cfg "s3://$CONFIG_S3_BUCKET_NAME"

# rm -v ~/.aws/credentials

  cat << EOF_04 > ~/.aws/credentials.minio
[minio]
aws_access_key_id = $MINIO_ACCESS_KEY
aws_secret_access_key = $MINIO_SECRET_KEY
region = $MINIO_REGION

EOF_04

	export AWS_ACCESS_KEY="$MINIO_ACCESS_KEY"
	export AWS_SECRET_ACCESS_KEY="$MINIO_SECRET_KEY"
	# aws s3 ls --profile minio --endpoint-url "$CONFIG_S3_ENDPOINT" --no-verify-ssl true
  # aws  --profile minio --endpoint-url "$CONFIG_S3_ENDPOINT" s3 ls --no-verify-ssl true s3://ava-local-bucket
  AWS_SHARED_CREDENTIALS_FILE=~/.aws/credentials.minio aws s3 ls --recursive --profile minio --endpoint-url "$CONFIG_S3_ENDPOINT" --no-verify-ssl s3://ava-local-bucket

  export exit_code=$?
}
