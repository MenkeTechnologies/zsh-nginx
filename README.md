```
 ███████╗███████╗██╗  ██╗
 ╚══███╔╝██╔════╝██║  ██║
   ███╔╝ ███████╗███████║
  ███╔╝  ╚════██║██╔══██║
 ███████╗███████║██║  ██║
 ╚══════╝╚══════╝╚═╝  ╚═╝
       [ n g i n x ]
```

[![CI](https://github.com/MenkeTechnologies/zsh-nginx/actions/workflows/ci.yml/badge.svg)](https://github.com/MenkeTechnologies/zsh-nginx/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![zsh](https://img.shields.io/badge/zsh-plugin-cyan.svg)](https://github.com/MenkeTechnologies/zpwr)

### `[NGINX COMPLETION FOR ZSH]`

> *"nginx commands, one tab away."*

### [`strykelang`](https://github.com/MenkeTechnologies/strykelang) &middot; [`zshrs`](https://github.com/MenkeTechnologies/zshrs) · [`MenkeTechnologiesMeta`](https://github.com/MenkeTechnologies/MenkeTechnologiesMeta) · [`zsh-more-completions`](https://github.com/MenkeTechnologies/zsh-more-completions) · [`zpwr`](https://github.com/MenkeTechnologies/zpwr)

### [`Read the Docs`](https://menketechnologies.github.io/zsh-nginx/) &middot; [`Engineering Report`](https://menketechnologies.github.io/zsh-nginx/report.html)

---

## Table of Contents

- [\[0x00\] Install for Zinit](#0x00-install-for-zinit)
- [\[0x01\] Install for Oh My Zsh](#0x01-install-for-oh-my-zsh)
- [\[0x02\] General Install](#0x02-general-install)
- [\[0x03\] Commands](#0x03-commands)

---

## [0x00] Install for Zinit
> `~/.zshrc`
```sh
source "$HOME/.zinit/bin/zinit.zsh"
zinit ice lucid nocompile
zinit load MenkeTechnologies/zsh-nginx
```

## [0x01] Install for Oh My Zsh

```sh
cd "$HOME/.oh-my-zsh/custom/plugins"  && git clone https://github.com/MenkeTechnologies/zsh-nginx.git
```

Add `zsh-nginx` to plugins array in ~/.zshrc

## [0x02] General Install

```sh
git clone https://github.com/MenkeTechnologies/zsh-nginx.git
```

source zsh-nginx.plugin.zsh or add code to zshrc or any startup script


## [0x03] Commands

Aliases:

| Alias | Expands to |
| --- | --- |
| `ngt` | `nginx -t` (via `sudo` when available) |
| `ngr` | `service nginx restart` (via `sudo` when available) |

Functions (autoloaded from `autoload/`; completions in `src/`):

| Command | Description |
| --- | --- |
| `en NAME` | Symlink `sites-available/NAME` into `sites-enabled/` |
| `dis NAME` | Remove `sites-enabled/NAME` |
| `vhost [-l] [-u USER] [-t TEMPLATE] [-n] [-w] [-h] NAME` | Generate `sites-available/NAME` from a template and enable it. `-l` lists enabled vhosts, `-n` skips enabling, `-w` appends NAME to the first line of `/etc/hosts`, `-h` prints usage |

Variables:

| Variable | Default | Description |
| --- | --- | --- |
| `NGINX_DIR` | `/etc/nginx` | nginx configuration directory |
| `NGINX_VHOST_TEMPLATE` | `$ZSH/plugins/nginx/templates/symfony2` | Default vhost template; `-t` selects another from `$ZSH/plugins/nginx/templates/` or a file path |
