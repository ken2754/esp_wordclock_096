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
    set t_ku= OA
    set t_kd= OB
    set t_kr= OC
    set t_kl= OD
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

if hostname() ==# 'penguin'
    call plug#begin()
    Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
    Plug 'dense-analysis/ale'
    call plug#end()
    let g:ale_linters = {'sh': ['shellcheck']}
endif

