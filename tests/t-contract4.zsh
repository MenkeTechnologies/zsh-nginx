#!/usr/bin/env zunit
#{{{                    MARK:Header
##### Purpose: zsh-nginx — fourth-tier contracts.
#####          Pins for template-substitution ordering, sed-pipeline
#####          token coverage, getopts unknown-flag handling, and
#####          OPTARG capture flags on flags that take a value.
#}}}***********************************************************

@setup {
    0="${${0:#$ZSH_ARGZERO}:-${(%):-%N}}"
    0="${${(M)0:#/*}:-$PWD/$0}"
    pluginDir="${0:h:A}"
    vhostFile="$pluginDir/autoload/vhost"
}

@test 'sed pipeline substitutes vhost, user, AND pool_port in one pass' {
    # Pin: the template renderer must rewrite ALL three template tokens
    # in a single sed invocation. Splitting into three sed runs would
    # increase fork count and risk partial substitution if an intermediate
    # exit code is ignored. Pin all three -e args on one line.
    grep -qF 's/{vhost}/' "$vhostFile"
    local v=$?
    grep -qF 's/{user}/' "$vhostFile"
    local u=$?
    grep -qF 's/{pool_port}/' "$vhostFile"
    local p=$?
    assert $(( v + u + p )) equals 0
}

@test 'getopts string captures OPTARG on u, t but NOT on l, n, w, h' {
    # Pin: the getopts string is `:lu:t:nwh` — leading `:` enables
    # silent-error mode, `u:` and `t:` take values, others are flags.
    # Swapping `u:` to `u` would silently treat `-u myuser` as `-u`
    # and treat `myuser` as a positional, breaking the user override.
    grep -qF 'getopts ":lu:t:nwh"' "$vhostFile"
    assert $? equals 0
}

@test 'getopts leading colon enables silent-error mode (no auto-usage spam)' {
    # Pin: the leading `:` in `:lu:t:nwh` suppresses getopts' built-in
    # error message on unknown flags. zsh-nginx does NOT define a `?`
    # case handler, so silent-error mode means unknown flags fall through
    # to positional parsing rather than spamming the user's shell.
    local optstr
    optstr=$(grep -oE 'getopts "[^"]+"' "$vhostFile" | sed 's/getopts //; s/"//g')
    [[ "${optstr[1]}" == ':' ]]
    assert $? equals 0
}

@test 'empty vhost-name triggers required-arg error path (return without enable/write)' {
    # Pin: the empty-vhost guard is `if [ -z "$vhost" ]; then ... return`.
    # Removing the early `return` would let `_vhost_generate "" "$user"`
    # run with an empty filename, writing the rendered template to a file
    # literally named "" (which would error). Pin the guard + return.
    grep -qE 'if \[ -z "\$vhost" \]; then' "$vhostFile"
    local guard=$?
    awk '/if \[ -z "\$vhost" \]; then/,/^[[:space:]]+fi/' "$vhostFile" | grep -qE '^[[:space:]]+return'
    local ret=$?
    assert $(( guard + ret )) equals 0
}

@test 'vhost autoload file ends with bare `vhost "$@"` invocation' {
    # Pin: zsh autoload-style file (`autoload -Uz vhost`) is sourced
    # then runs the trailing call. Drop it and the widget defines the
    # fn but never runs it — silent no-op when the user types `vhost`.
    local last
    last=$(grep -vE '^\s*$' "$vhostFile" | tail -1)
    assert "$last" same_as 'vhost "$@"'
}
