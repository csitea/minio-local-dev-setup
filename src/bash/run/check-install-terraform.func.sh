#!/usr/bin/env bash
# attempt to install terraform, if it is missing!!! Obs needs sudo!!!
do_check_install_terraform() {
  export DEBIAN_FRONTEND=noninteractive
  package='terraform'
  # defined in the Makefile or the calling shell
  required_ver="${TERRAFORM_REQUIRED_VERSION:-}" # exported from Makefile
  test -z ${required_ver:-} && required_ver='1.1.9'

  if [ "$(uname)" == "Darwin" ]; then
    os='darwin_amd64'
  elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    os='linux_amd64'
  fi

  download_fle='/tmp/'"${package}"'_'"$required_ver"'_'"$os"'.zip'
  which $package 2>/dev/null || {

    wget -O "$download_fle" \
      "https://releases.hashicorp.com/$package/$required_ver/${package}_""$required_ver"'_'$os'.zip'
    sudo unzip -o $download_fle -d '/usr/local/bin'
    $package --version
  }

  deployed_ver=$(terraform --version | head -n1 | tr -d 'Terraform v')
  [[ "$required_ver" == "$deployed_ver" ]] || {
    wget -O "$download_fle" \
      "https://releases.hashicorp.com/$package/$required_ver/${package}_""$required_ver"'_'$os'.zip'
    sudo unzip -o $download_fle -d '/usr/local/bin'
    $package --version
  }

  which $package 2>/dev/null || {
    echo >&2 "The $package binary is missing ! Aborting ..."
    exit 1
  }

  which $package && echo "$package is deployed and runnable."

  deployed_ver=$(terraform --version | head -n1 | tr -d 'Terraform v')
  [[ "$required_ver" == "$deployed_ver" ]] && {
    echo "$package $required_ver is present and available."
  }
  [[ "$required_ver" == "$deployed_ver" ]] || {
    echo >&2 "The $required_ver version is missing ! Aborting ..."
    exit 1
  }
  export exit_code=0
}
