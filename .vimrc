syntax on
filetype plugin indent on
set number
set clipboard=unnamed,unnamedplus
set mouse=a
set tabstop=4
set shiftwidth=4
set expandtab
set nocompatible

" --- カーソルキー / 端末依存の修正 ---
" Windows(win32/64) 以外、かつ SSH 接続時や特定ターミナルで有効化
if has('unix') && !has('gui_running')
    " すべての UNIX 系環境（Penguin, ArkOS, dArkOS）で適用
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

let s:plug_dir = has('win32') || has('win64') ? '~/vimfiles/plugged' : '~/.vim/plugged'

call plug#begin(s:plug_dir)
    " 汎用
    Plug 'dense-analysis/ale'
    " 言語別
    Plug 'pprovost/vim-ps1'        " PowerShell (Windows/Linux共用)
    Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' } " Go
call plug#end()

" --- 4. OS/環境別・微調整 ---
" Windows ターミナルの設定
if has('win32') || has('win64')
    set shell=powershell.exe
endif
