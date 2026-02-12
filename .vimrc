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
if has('gui_running')
  if has('win32') || has('win64')
    set guifont=Noto_Sans_Mono_CJK_JP:h12
  elseif has('unix')
    set guifont=Noto\ Sans\ Mono\ CJK\ JP\ 12
  endif
endif
set encoding=utf-8
set fileencodings=utf-8,iso-2022-jp,euc-jp,sjis

set number
set wrap
set tabstop=4
set shiftwidth=4
set expandtab

let g:markdown_fenced_languages = ['go', 'python', 'javascript', 'vim']

set splitright
set splitbelow
set foldmethod=marker

set background=dark
colorscheme retrobox
" }}}

" KEY {{{
nnoremap j gj
nnoremap k gk

nnoremap <Space> za

if has('unix') && !has('gui_running')
    set t_ku=OA
    set t_kd=OB
    set t_kr=OC
    set t_kl=OD
endif
" }}}

" OSC52 {{{
if has('unix')
    set clipboard=unnamedplus

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
" }}}

" PLUGIN {{{
let s:plug_dir = '~/.vim/plugged'
call plug#begin(s:plug_dir)
    Plug 'dense-analysis/ale'
    Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
    Plug 'davidoc/taskpaper.vim'
call plug#end()
" }}}

" GEMINI {{{
command! GeminiChat :vertical terminal ++close env GEMINI_API_KEY= gemini
" }}}

" TASKPAPER {{{
augroup TaskPaperAutoSync
    autocmd!
    autocmd BufWritePost *.taskpaper execute 'terminal ++rows=10 ' . expand('~/git/todo/tpush.sh')
augroup END
" }}}
