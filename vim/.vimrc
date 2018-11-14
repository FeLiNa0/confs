" use Vim defaults instead of Vi's
" warning: keep this near the top of the config file
set nocompatible

" junnegunn/vim-plug
" need .vim/autoload/plug.vim
" call :PlugInstall to install and update
call plug#begin()

" Theme
Plug 'dylanaraps/wal.vim'

" good default settings
" "one step above the nocompatible setting"
" A taste of its features:
"   'backspace': Backspace through anything in insert mode.
"   'incsearch': Start searching before pressing enter.
"   'listchars': Makes :set list (visible whitespace) prettier.
"   'scrolloff': Always show at least one line above/below the cursor.
"   'autoread': Autoload file changes. You can undo by pressing u.
"   runtime! macros/matchit.vim: Load the version of matchit.vim that ships with Vim.
Plug 'tpope/vim-sensible'

" Various language syntax definitions. Loads much faster than individual plugins.
" Languages supported as of 09/2018:
" ansible, apiblueprint, applescript, arduino, asciidoc, autohotkey, blade,
" c++11, c/c++, caddyfile, carp, cjsx, clojure, cmake, coffee-script, cql,
" cryptol, crystal, cucumber, dart, dockerfile, elixir, elm, emberscript,
" emblem, erlang, ferm, fish, fsharp, git, glsl, gmpl, gnuplot, go, graphql,
" groovy, haml, handlebars, haproxy, haskell, haxe, html5, i3, jasmine,
" javascript, jenkins, json5, json, jst, jsx, julia, kotlin, latex, less,
" liquid, livescript, lua, mako, markdown, mathematica, nginx, nim, nix,
" objc, ocaml, octave, opencl, perl, pgsql, php, plantuml, powershell,
" protobuf, pug, puppet, purescript, python-compiler, python-ident, python,
" qml, r-lang, racket, ragel, raml, rspec, ruby, rust, sbt, scala, scss,
" slim, slime, solidity, stylus, swift, sxhkd, systemd, terraform, textile,
" thrift, tmux, tomdoc, toml, twig, typescript, vala, vbnet, vcl, vifm, vm,
" vue, xls, yaml, yard
Plug 'sheerun/vim-polyglot'
let g:polyglot_disabled = ['python', 'ocaml']

" Deoplete code completion framework
" https://github.com/Shougo/deoplete.nvim/wiki/Completion-Sources
if has('nvim')
  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
else
  Plug 'Shougo/deoplete.nvim'
  Plug 'roxma/nvim-yarp'
  Plug 'roxma/vim-hug-neovim-rpc'
endif

let g:deoplete#enable_at_startup = 1
let g:deoplete#complete_method = "complete" " merlin compat?
let g:deoplete#auto_complete_delay = 0

" USE TAB!!!!!!
inoremap <expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"

" Completion based on syntax
Plug 'Shougo/neco-syntax'

" merlin, autocomplete for ocaml
" TODO only load for ocaml
let g:opamshare = substitute(system('opam config var share'),'\n$','','''')
execute 'set rtp+=' . g:opamshare . '/merlin/vim'
execute 'set rtp+=' . g:opamshare . '/ocp-indent/vim'

" Completion for ocaml using merlin
" install merline with:
" opam install merlin

Plug 'rgrinberg/vim-ocaml', { 'for': 'ocaml' }

" deoplete and ocaml
Plug 'copy/deoplete-ocaml', { 'for': 'ocaml' }

" Reason
Plug 'reasonml-editor/vim-reason-plus'

" Haskell
" needs ghc-mod
Plug 'eagletmt/neco-ghc', { 'for': 'haskell' }
let g:haskellmode_completion_ghc = 0
autocmd FileType haskell setlocal omnifunc=necoghc#omnifunc

" Python code-completion, many other features
Plug 'davidhalter/jedi-vim', { 'for': 'python' }
Plug 'zchee/deoplete-jedi'

" J, APL derivative
Plug 'guersam/vim-j'

" HTML, CSS
Plug 'othree/html5.vim'
Plug 'ap/vim-css-color'

" JS, libraries 
Plug 'pangloss/vim-javascript', { 'for': 'javascript' }
Plug 'othree/javascript-libraries-syntax.vim', { 'for': 'javascript' }
Plug 'wokalski/autocomplete-flow', { 'for': 'javascript' }

" Rust
Plug 'racer-rust/vim-racer', { 'for': 'rust' }

" JS Elm
" Plug 'ElmCast/elm-vim'

" Pandoc
Plug 'vim-pandoc/vim-pandoc'
Plug 'vim-pandoc/vim-pandoc-syntax'

" handlebar and mustache templates
" Plug 'mustache/vim-mustache-handlebars'
" Plug 'evidens/vim-twig'
" Plug 'lepture/vim-jinja'

" org mode
Plug 'jceb/vim-orgmode', { 'for': 'org' }
" Plug 'jwiegley/org-mode', { 'for': 'org' }

" syntax highlighting for COOL
au BufNewFile,BufRead *.cool setf cool 
au BufNewFile,BufRead *.cl setf cool 
Plug 'vim-scripts/cool.vim', { 'for': 'cool' }

" linters (syntax checkers, other code checkers)
Plug 'scrooloose/syntastic'

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 0
let g:syntastic_check_on_wq = 0
" show warnings AND errors
let g:syntastic_quiet_messages = {'level': 'none'} 

let g:syntastic_rust_checkers = ['cargo']

let g:syntastic_python_checkers = ['python', 'flake8', 'pycodestyle', 'pylint']
let g:syntastic_python_pylint_exe = 'pylint'

let g:syntastic_tex_checkers = ['chktex']

let g:syntastic_javascript_checkers = ['eslint', 'flow']

let g:syntastic_html_checkers = ['tidy', 'jshint']

" let g:syntastic_css_checkers = ['csslint', 'stylelint']

let g:syntastic_typescript_checkers = ['tslint']

let g:syntastic_cpp_compiler = 'clang++'
let g:syntastic_cpp_compiler_options = ' -std=c++11'

let g:syntastic_c_checkers = ['clang_check', 'gcc', 'splint', 'clang_tidy']
let g:syntastic_cpp_checkers = ['clang_check', 'gcc', 'splint', 'clang_tidy']

let g:syntastic_ocaml_checkers = ['merlin']

" treat contents of some tex environments as verbatim text
au filetype tex syntax region texZone start='\\begin{lstlisting}' end='\\end{lstlisting}'
au filetype tex syntax region texZone start='\\begin{python3code}' end='\\end{python3code}'
au filetype tex syntax region texZone start='\\begin{bashcode}' end='\\end{bashcode}'
au filetype tex syntax region texZone start='\\begin{pyconcode}' end='\\end{pyconcode}'

" Improved syntax highlighting for C, add syntax highlighting for Bison, and Flex
Plug 'justinmk/vim-syntax-extra', { 'for': [ 'c', 'cpp', 'y', 'l' ] }

call plug#end()

" read the real vim config
if filereadable(expand('~/.vimrc.minimal'))
    so ~/.vimrc.minimal
endif

" switch to wal colorscheme if wal theme exists 
if filereadable(expand('~/.vim/plugged/wal.vim/colors/wal.vim'))
    execute 'silent colorscheme wal'
endif
