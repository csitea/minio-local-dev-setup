#!/bin/bash 

do_monitor_poke_api(){

  do_require_var ENV ${ENV:-}
  code=$(curl --max-time 3 -s 'https://apiv2-'$ENV'.spectralengines.com/health' -o /dev/null -w '%{http_code}\n' -s)
  echo code=$code

  curl --max-time 3 -s 'https://apiv2-'$ENV'.spectralengines.com/health' -o /dev/null -w '%{http_code}\n' -s
  rv=$?

  cp -v $PRODUCT_DIR/dat/tpl/src/nodejs/status-monitor/src/mock/tableFill.json.tpl \
    $PRODUCT_DIR/src/nodejs/status-monitor/src/mock/tableFill.json
  perl -pi -e "s|%code%|$code|g" $PRODUCT_DIR/src/nodejs/status-monitor/src/mock/tableFill.json


  msg=''
  case "$code" in
    '200') msg="all is good" ;;
    '404') msg="the resource was not found";;
    *) msg="an unknown error occurred" ;;
  esac
  perl -pi -e "s|%msg%|$msg|g" $PRODUCT_DIR/src/nodejs/status-monitor/src/mock/tableFill.json


  status=''
  case "$code" in
    '200') status="OK" ;;
    '404') status="FAILURE";;
    *) status="NOK" ;;
  esac
  perl -pi -e "s|%status%|$status|g" $PRODUCT_DIR/src/nodejs/status-monitor/src/mock/tableFill.json


  test $rv -eq 0 && export exit_code=0

}
