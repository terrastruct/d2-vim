<div align="center">
  <h1 align="center">
    <img src="./logo.svg" alt="D2" />
  </h1>

The Vim plugin for [D2](https://d2-lang.com) files.
<br />
<br />
</div>



```vim
" Using https://github.com/junegunn/vim-plug
Plug 'terrastruct/d2-vim'
```

See `:help d2-vim` or [./doc/d2.txt](./doc/d2.txt) for options and additional documentation.

```d2
x -> y

# d2-vim can syntax highlight nested markdown correctly.
y: |`md
  # d2-vim
  The Vim plugin for [D2](https://d2-lang.com) files.
`|
```
