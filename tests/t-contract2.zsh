#!/usr/bin/env zunit
#{{{                    MARK:Header
##### Purpose: zsh-nginx — second-tier contract pins.
#####          Cover surfaces not pinned by t-aliases/t-syntax:
#####          completion file #compdef directives, NGINX_DIR
#####          default + override behavior, template directory
#####          structure, sudo fallback when missing.
#}}}***********************************************************

@setup {
    0="${${0:#$ZSH_ARGZERO}:-${(%):-%N}}"
    0="${${(M)0:#/*}:-$PWD/$0}"
    pluginDir="${0:h:A}"
    pluginFile="$pluginDir/zsh-nginx.plugin.zsh"
}

@test 'every completion file in src/ starts with #compdef <cmd> matching its name' {
    # Pin: completion files must have #compdef matching the disabled/
    # enabled/vhost helper fn names. Renaming the fn without updating
    # the directive silently disables completion.
    local missing=""
    local f base expected first
    for f in "$pluginDir/src/"_*; do
        [[ -f "$f" ]] || continue
        base="${f##*/_nginx_}"
        first=$(head -1 "$f")
        expected="#compdef $base"
        [[ "$first" == "$expected" ]] || missing="$missing ${f##*/}:got=[$first]want=[$expected]"
    done
    assert "$missing" is_empty
}

@test 'NGINX_DIR defaults to /etc/nginx when unset (POSIX nginx FHS path)' {
    # Pin: the : ${VAR:=default} form sets the default. Removing the
    # : prefix would silently print the path on every shell start.
    local out
    out=$(unset NGINX_DIR; zsh -c "
        source '$pluginFile' 2>/dev/null
        print \"\$NGINX_DIR\"
    ")
    assert "$out" same_as '/etc/nginx'
}

@test 'NGINX_DIR caller override is preserved (no clobber)' {
    # Pin: : ${VAR:=...} only sets when unset/null. Pre-setting it
    # to a custom path must survive sourcing.
    local out
    out=$(NGINX_DIR=/custom/nginx zsh -c "
        source '$pluginFile' 2>/dev/null
        print \"\$NGINX_DIR\"
    ")
    assert "$out" same_as '/custom/nginx'
}

@test 'sudo fallback to empty string when sudo binary missing' {
    # Pin: the if/else around `which -p sudo` ensures plugin loads on
    # hosts without sudo (containers, CI). The fallback sets sudo="".
    # Verify the source has both branches.
    grep -qE 'if \[\[ -e \$\( which -p sudo' "$pluginFile"
    assert $? equals 0
    grep -qE 'sudo=""' "$pluginFile"
    assert $? equals 0
}

@test 'templates directory ships at least one ready-made template (no empty install)' {
    # Pin: the README documents vhost templates. The repo must ship
    # at least one or the `vhost` fn would fail with template-not-found
    # on a fresh install.
    local count
    count=$(ls -1 "$pluginDir/templates/" 2>/dev/null | wc -l | tr -d ' ' || true)
    [[ "$count" -ge 1 ]]
    assert $? equals 0
}

@test 'autoload directory exposes exactly the dis/en/vhost helpers' {
    # Pin: en/dis/vhost are the user-visible commands. Adding new
    # ones needs deliberate review (potential alias collision risk).
    local files
    files=$(ls -1 "$pluginDir/autoload/" | sort | tr '\n' ' ')
    assert "$files" same_as 'dis en vhost '
}
