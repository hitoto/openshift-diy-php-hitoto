# Warning: Be careful with modifications to this file,
#          Your changes may cause your application to fail.

alias phpdiy='$OPENSHIFT_HOMEDIR/app-root/runtime/srv/php/bin/php'
alias l='ls -alF'
alias ..='cd ..'

alias apastart='$OPENSHIFT_HOMEDIR/app-root/runtime/srv/httpd/bin/apachectl start'
alias apastop='$OPENSHIFT_HOMEDIR/app-root/runtime/srv/httpd/bin/apachectl stop'
PATH=$OPENSHIFT_RUNTIME_DIR/srv/openssl/bin:$OPENSHIFT_RUNTIME_DIR/srv/curl/bin:$PATH
export PATH
