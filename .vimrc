" GENERAL {{{
set runtimepath+=$HOME/.vim
set nocompatible

if has('clipboard')
    if has('win32') || has('win64')
        set clipboard=unnamed
        augroup FixWindowsYank
            autocmd!
            autocmd TextYankPost * let @* = @"
        augroup END
    else
        set clipboard=unnamedplus
    endif
endif

set mouse=a
set visualbell t_vb=
set noerrorbells

if !isdirectory(expand('~/.vim/swap'))
    call mkdir(expand('~/.vim/swap'), 'p')
endif

if executable('pwsh')
    set shell=pwsh
    set shellcmdflag=-c
    set shellquote=
    set shellxquote=
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

let g:markdown_fenced_languages = ['go', 'python', 'javascript', 'powershell', 'vim']

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

inoremap ( ()<Left>
inoremap { {}<Left>
inoremap [ []<Left>
inoremap " ""<Left>
inoremap ' ''<Left>

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
    Plug 'stefandtw/quickfix-reflector.vim'
call plug#end()
" }}}

" GEMINI {{{
command! GeminiChat :vertical terminal ++cols=40 ++close
" }}}

" TASKPAPER {{{
augroup TaskPaperAutoSync
    autocmd!
    autocmd BufWritePost *.taskpaper call s:sync_taskpaper()
    autocmd VimLeavePre  *.taskpaper call s:sync_taskpaper()
augroup END

function! s:sync_taskpaper()
    let l:path = expand('$HOME/git/todo/tpush.sh')
    if has('win32')
        let l:path = tr(l:path, '\', '/')
    endif
    let l:cmd = "sh \"" . l:path . "\""
    execute "term " . l:cmd
    wincmd p
endfunction

command! Ttoday call s:replace_start_with_today()

function! s:replace_start_with_today() abort
  let l:today = strftime('%Y-%m-%d')
  silent! execute '%s/@start(\zs\d\{4}-\d\{2}-\d\{2}\ze)/\=s:compare_and_replace(submatch(0), l:today)/ge'
  silent! execute '%s/@start(today)/@today/ge'
  silent! execute 'global/@done/s/\s\+@today//ge'
  silent! execute 'global/@done/s/@today\s*//ge'
  execute "normal \<Plug>TaskPaperShowToday"
  normal gg
  set nohlsearch
  echo "Ready for today!"
endfunction

function! s:compare_and_replace(date_str, today_str) abort
  if a:date_str <= a:today_str
    return "today"
  endif
  return a:date_str
endfunction
" }}}
