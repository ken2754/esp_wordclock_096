syntax on
filetype plugin indent on

set number
set clipboard=unnamedplus

set mouse=a
set tabstop=4
set shiftwidth=4
set expandtab

set nocompatible
set t_ku=OA
set t_kd=OB
set t_kr=OC
set t_kl=OD

" 2026/2/1 OSC 52 非対応端末対応
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

if hostname() ==# 'penguin'
    call plug#begin()
    Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
    Plug 'dense-analysis/ale'
    call plug#end()
    let g:ale_linters = {'sh': ['shellcheck']}
endif

