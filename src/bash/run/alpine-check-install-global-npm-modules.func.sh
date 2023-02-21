#!/bin/bash
do_alpine_check_install_global_npm_modules(){

   # install the npm modules from the list file
   npm_modules_lst_fle=${1:-$PRODUCT_DIR/src/docker/status-monitor-ui/status-monitor-global-npm-modules.lst}

   # if the nodejs bin does not exist install it ...
   which node 2>/dev/null || {
      run_os_func check_install_nodejs
   }

   export PUPPETEER_SKIP_DOWNLOAD='true'

   while read -r npm_module ; do (
      set -e
      sudo npm install -g "$npm_module"
      test "$?" -ne 0 && exit "$?"
      sudo npm link "$npm_module"
      set +e
   );
   done < <(cat $npm_modules_lst_fle)

   export exit_code="0"
}
