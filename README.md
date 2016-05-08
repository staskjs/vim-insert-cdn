# vim-insert-cdn

Need to quickly insert a cdn link to a javascript library, but you're already tired of googling it everytime?
vim-insert-cdn does just that.

## Installation

If you use pathogen:

```sh
$ cd ~/.vim/bundle && git clone https://github.com/staskjs/vim-insert-cdn.git
```

## Usage

Plugin exposes a command:

```
:InsertScriptTag package_name
```

package_name is a npm-like notion. You can write `:InsertScriptTag jquery@1.10.0` or without a version `:InsertScriptTag jquery`

## API

Plugin uses [jsdelivr.com](jsdelivr.com) API to get information about packages.
