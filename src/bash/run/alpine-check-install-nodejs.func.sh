#!/bin/bash
do_alpine_check_install_nodejs(){


   sudo apk add --update nodejs
   sudo apk add --update nodejs-npm
   sudo apk add --update npm

   command -v yarn || {
      sudo npm install -g yarn
   }

    echo -e "\nnode version: $(node --version)"
    echo -e "\nnpm version: $(npm --version)"
    echo -e "\nyarn version: $(yarn --version)\n"

   export exit_code="0"
}
