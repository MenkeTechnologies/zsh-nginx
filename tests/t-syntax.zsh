#!/usr/bin/env zunit
#{{{                    MARK:Header
#**************************************************************
##### Author: MenkeTechnologies
##### GitHub: https://github.com/MenkeTechnologies
##### Date: Tue Feb 25 19:37:50 EST 2020
##### Purpose: zsh script to
##### Notes:
#}}}***********************************************************

@setup {
    0="${${0:#$ZSH_ARGZERO}:-${(%):-%N}}"
    0="${${(M)0:#/*}:-$PWD/$0}"
    pluginDir="${0:h:A}"
}

@test 'plugin *.zsh' {
	for file in "$pluginDir/"*.zsh; do
        run zsh -n "$file"
        assert $state equals 0
    done
}

@test 'autoload *.zsh' {
	for file in "$pluginDir/autoload/"*; do
        run zsh -n "$file"
        assert $state equals 0
    done
}

@test 'autoload/ holds the 3 documented helper fns' {
    # README documents dis / en / vhost helpers — pin the file set
    # so a rename to e.g. `disable` silently breaks downstream
    # `autoload -Uz dis` calls.
    [[ -f "$pluginDir/autoload/dis" ]]
    assert $state equals 0
    [[ -f "$pluginDir/autoload/en" ]]
    assert $state equals 0
    [[ -f "$pluginDir/autoload/vhost" ]]
    assert $state equals 0
}

@test 'every autoload file is syntactically a function body (no #!shebang required)' {
    # `autoload -Uz` expects the file to BE the function body; a
    # shebang or `function name() {` wrapper breaks the autoload
    # contract silently (the fn ends up needing a manual call form).
    local bad=""
    for file in "$pluginDir/autoload/"*; do
        [[ -f "$file" ]] || continue
        local first
        first=$(head -1 "$file")
        # Allow a leading comment line, but not a `#!shebang`.
        [[ "$first" =~ ^#! ]] && bad="$bad ${file##*/}"
    done
    assert "$bad" is_empty
}

@test 'README references the plugin entrypoint filename' {
    run grep -F 'zsh-nginx.plugin.zsh' "$pluginDir/README.md"
    assert $state equals 0
}

@test 'templates/ holds at least one vhost template' {
    # `vhost` helper copies from templates/<name>/; if the dir is
    # empty, `vhost mysite` would silently produce an empty config.
    run sh -c "ls -1 '$pluginDir/templates' | wc -l | tr -d ' '"
    assert $state equals 0
    [[ "$output" -ge 1 ]]
    assert $state equals 0
}
