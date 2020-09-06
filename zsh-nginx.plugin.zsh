: ${NGINX_DIR:=/etc/nginx}
: ${NGINX_VHOST_TEMPLATE:=$ZSH/plugins/nginx/templates/symfony2}

if [[ -e $( which -p sudo 2>&1 ) ]]; then
    sudo="sudo"
else
    sudo=""
fi

alias ngt="$sudo nginx -t"
alias ngr="$sudo service nginx restart"

0="${${0:#$ZSH_ARGZERO}:-${(%):-%N}}"
0="${${(M)0:#/*}:-$PWD/$0}"

# comps
fpath=("${0:h}/src" $fpath)

# util fns
fpath+=("${0:h}/autoload")
autoload -Uz "${0:h}/autoload/"*(.:t)
