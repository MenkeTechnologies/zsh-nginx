#!/usr/bin/env zunit
#{{{                    MARK:Header
##### Purpose: zsh-nginx — third-tier surface pins:
#####          - both templates contain the {vhost} placeholder (the substitution target)
#####          - both templates contain the {user} placeholder (sed -e 's/{user}/.../g')
#####          - vhost fn parses options via getopts (NOT zparseopts — bash compat)
#####          - getopts option string lists every flag advertised in _vhost_usage
#####          - en/dis use $sudo (NOT bare sudo) so non-root hosts work
#}}}***********************************************************

@setup {
    0="${${0:#$ZSH_ARGZERO}:-${(%):-%N}}"
    0="${${(M)0:#/*}:-$PWD/$0}"
    pluginDir="${0:h:A}"
    pluginFile="$pluginDir/zsh-nginx.plugin.zsh"
    vhostFile="$pluginDir/autoload/vhost"
    enFile="$pluginDir/autoload/en"
    disFile="$pluginDir/autoload/dis"
    tplDir="$pluginDir/templates"
}

@test 'both vhost templates contain {vhost} placeholder (sed substitution target)' {
    # Pin: `sed -e 's/{vhost}/.../g'` requires `{vhost}` to be present
    # in the template. Without it, the substitution is a no-op and the
    # generated config has no server_name.
    local missing=""
    local t
    for t in "$tplDir"/*; do
        [[ -f "$t" ]] || continue
        grep -qF '{vhost}' "$t" || missing="$missing ${t##*/}"
    done
    assert "$missing" is_empty
}

@test 'both vhost templates contain {user} placeholder (sed substitution target)' {
    local missing=""
    local t
    for t in "$tplDir"/*; do
        [[ -f "$t" ]] || continue
        grep -qF '{user}' "$t" || missing="$missing ${t##*/}"
    done
    assert "$missing" is_empty
}

@test 'vhost parses options via getopts (the bash-compat option parser)' {
    # Pin: vhost uses getopts (POSIX) not zparseopts (zsh-only) so the
    # autoload can be sourced under bash-compat emulation if needed.
    grep -qE 'while getopts ' "$vhostFile"
    assert $? equals 0
}

@test 'getopts string covers every flag documented in _vhost_usage (l/u/t/n/w/h)' {
    # Pin: the getopts string and the usage doc must agree. Drift means
    # users see a flag in -h but the parser silently rejects it.
    local optstr
    optstr=$(grep -oE 'getopts ":[a-z:]+"' "$vhostFile" | head -1 | sed -E 's/.*":([a-z:]+)".*/\1/')
    # strip ':' (those mark "takes argument"): result must contain l u t n w h
    local stripped="${optstr//:/}"
    local missing=""
    local f
    for f in l u t n w h; do
        [[ "$stripped" == *"$f"* ]] || missing="$missing $f"
    done
    assert "$missing" is_empty
}

@test 'en and dis use $sudo variable (NOT bare sudo) for privilege drop on non-root hosts' {
    # Pin: the plugin sets `sudo="sudo"` only when sudo is on PATH;
    # otherwise sudo="". Calls MUST use `$sudo` so an unprivileged host
    # without sudo still attempts the op as the current user, rather
    # than failing with `sudo: command not found`.
    local fail=""
    if grep -qE '^[[:space:]]*sudo[[:space:]]+(ln|rm|mv)[[:space:]]' "$enFile"; then
        fail="$fail en-bare-sudo"
    fi
    if grep -qE '^[[:space:]]*sudo[[:space:]]+(ln|rm|mv)[[:space:]]' "$disFile"; then
        fail="$fail dis-bare-sudo"
    fi
    assert "$fail" is_empty
}
