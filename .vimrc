" GENERAL
set nocompatible
set clipboard=unnamedplus
set mouse=a

if !isdirectory(expand('~/.vim/swap'))
    call mkdir(expand('~/.vim/swap'), 'p')
endif
set directory=~/.vim/swap//

" SCREEN
syntax on
filetype plugin indent on
set guifont=Noto\ Sans\ Mono\ CJK\ JP\ Regular\ 12
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

set background=dark
colorscheme retrobox

" KEY
nnoremap j gj
nnoremap k gk

if has('unix') && !has('gui_running')
    set t_ku=OA
    set t_kd=OB
    set t_kr=OC
    set t_kl=OD
endif

" OSC52
if has('unix')
    set clipboard=unnamedplus

    function! OSC52Yank(str)
        " 外部ツールに頼らず base64 と echo で OSC52 シーケンスを作成
        let b64 = system('base64 | tr -d "\n"', a:str)
        let osc = "\e]52;c;" . b64 . "\x07"
        " /dev/tty (現在の端末) に直接書き込む
        call writefile([osc], '/dev/tty', 'ab')
    endfunction

    augroup osc52
        autocmd!
        autocmd TextYankPost * if v:event.operator == 'y' | call OSC52Yank(join(v:event.regcontents, "\n")) | endif
    augroup END
endif

" PLUGIN
let s:plug_dir = '~/.vim/plugged'
call plug#begin(s:plug_dir)
    Plug 'dense-analysis/ale'
    Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
    Plug 'cweagans/vim-taskpaper'
call plug#end()

" GEMINI
" 垂直分割で Gemini 対話画面（Google 認証優先モード）を開く
command! GeminiChat :vertical terminal ++close env GEMINI_API_KEY= gemini

