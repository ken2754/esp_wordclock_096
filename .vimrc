syntax on
filetype plugin indent on
set number
set clipboard=unnamedplus
set mouse=a
set tabstop=4
set shiftwidth=4
set expandtab
set nocompatible
set background=dark
colorscheme retrobox

if has('unix') && !has('gui_running')
    set t_ku=OA
    set t_kd=OB
    set t_kr=OC
    set t_kl=OD
endif

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

let s:plug_dir = '~/.vim/plugged'
call plug#begin(s:plug_dir)
    Plug 'dense-analysis/ale'
    Plug 'pprovost/vim-ps1'
    Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
call plug#end()
