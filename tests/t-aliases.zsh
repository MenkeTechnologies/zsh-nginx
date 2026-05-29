#!/usr/bin/env zunit
#{{{                    MARK:Header
#**************************************************************
##### Purpose: alias + fn pins for zsh-nginx. Plugin registers ngr/ngt
#####          aliases (nginx restart / test config) + dis/en/vhost
#####          helper fns (disable / enable / scaffold a vhost).
#}}}***********************************************************

@setup {
    0="${${0:#$ZSH_ARGZERO}:-${(%):-%N}}"
    0="${${(M)0:#/*}:-$PWD/$0}"
    pluginDir="${0:h:A}"
}

@test 'ngr alias restarts nginx via sudo service' {
    local body
    body=$(zsh -c "
        emulate zsh
        source '$pluginDir/zsh-nginx.plugin.zsh' 2>/dev/null
        alias ngr
    ")
    assert "$body" contains 'sudo'
    assert "$body" contains 'nginx restart'
}

@test 'ngt alias tests the nginx config via sudo nginx -t' {
    local body
    body=$(zsh -c "
        emulate zsh
        source '$pluginDir/zsh-nginx.plugin.zsh' 2>/dev/null
        alias ngt
    ")
    assert "$body" contains 'sudo nginx'
    assert "$body" contains '-t'
}

@test 'helper fn dis is defined' {
    local out
    out=$(zsh -c "
        emulate zsh
        source '$pluginDir/zsh-nginx.plugin.zsh' 2>/dev/null
        typeset -f dis >/dev/null && echo defined
    ")
    assert "$out" same_as 'defined'
}

@test 'helper fn en is defined' {
    local out
    out=$(zsh -c "
        emulate zsh
        source '$pluginDir/zsh-nginx.plugin.zsh' 2>/dev/null
        typeset -f en >/dev/null && echo defined
    ")
    assert "$out" same_as 'defined'
}

@test 'helper fn vhost is defined' {
    local out
    out=$(zsh -c "
        emulate zsh
        source '$pluginDir/zsh-nginx.plugin.zsh' 2>/dev/null
        typeset -f vhost >/dev/null && echo defined
    ")
    assert "$out" same_as 'defined'
}

@test 'plugin sourcing is idempotent' {
    local first second
    first=$(zsh -c "
        emulate zsh
        source '$pluginDir/zsh-nginx.plugin.zsh' 2>/dev/null
        alias | grep -cE '^ng'
    ")
    second=$(zsh -c "
        emulate zsh
        source '$pluginDir/zsh-nginx.plugin.zsh' 2>/dev/null
        source '$pluginDir/zsh-nginx.plugin.zsh' 2>/dev/null
        alias | grep -cE '^ng'
    ")
    assert "$first" equals "$second"
}
