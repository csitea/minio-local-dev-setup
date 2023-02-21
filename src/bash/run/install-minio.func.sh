#!/bin/bash

do_install_minio(){

	set -eu -o pipefail # fail on error , debug all lines

	# run as root
	[ "$USER" = "root" ] || exec sudo ./run -a do_install_minio "$@"

	doWgetMinioBins(){
		test -f /usr/local/bin/minio || wget -O /usr/local/bin/minio https://dl.minio.io/server/minio/release/linux-amd64/minio
		test -f /usr/local/bin/mc || wget -O /usr/local/bin/mc https://dl.minio.io/client/mc/release/linux-amd64/mc
		 sudo chmod 755 /usr/local/bin/minio
		 sudo chmod 755 /usr/local/bin/mc
		 ls -la /usr/local/bin/minio
		 ls -la /usr/local/bin/mc
	}

	do_log "INFO installing the must-have pre-requisites"
	while read -r p ; do
		 if [ "" == "`which $p`" ]; then
				doWgetMinioBins
		 fi
	done < <(cat << "EOF01"
		grep
		lsof
		pgrep
		openssl
		minio
EOF01
	)

  export exit_code=$?

}
