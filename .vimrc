" GENERAL {{{
set nocompatible
set clipboard=unnamedplus
set mouse=a

if !isdirectory(expand('~/.vim/swap'))
    call mkdir(expand('~/.vim/swap'), 'p')
endif
set directory=~/.vim/swap//
" }}}

" SCREEN {{{
syntax on
filetype plugin indent on

set number
set wrap
set tabstop=4
set shiftwidth=4
set expandtab
set foldmethod=marker

let g:markdown_fenced_languages = ['go', 'python', 'javascript', 'vim']

set splitright
set splitbelow

set background=dark
colorscheme retrobox
" }}}

" KEY {{{
nnoremap <Space> za

nnoremap j gj
nnoremap k gk

let mapleader = "\<Space>"

if has('unix') && !has('gui_running')
    set t_ku=OA
    set t_kd=OB
    set t_kr=OC
    set t_kl=OD
endif
" }}} 

" OSC52 {{{
if has('unix')
    if executable('pbcopy') || executable('xclip')
        function! OSC52Yank(str)
            let b64 = system('base64 | tr -d "\n"', a:str)
            let osc = "\e]52;c;" . b64 . "\x07"
            call writefile([osc], '/dev/tty', 'ab')
        endfunction
        augroup osc52
            autocmd!
            autocmd TextYankPost * if v:event.operator == 'y' | call OSC52Yank(join(v:event.regcontents, "\n")) | endif
        augroup END
    endif
endif
" }}}

" PLUGIN {{{
let s:plug_dir = '~/.vim/plugged'
call plug#begin(s:plug_dir)
    Plug 'dense-analysis/ale'
    Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
call plug#end()
" }}}

