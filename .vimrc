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
set breakindent
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
command! GeminiChat :vertical terminal ++cols=40 ++close GEMINI_API_KEY= gemini
" }}}

" TASKPAPER {{{
function! s:sync_taskpaper()
    let l:path = expand('$HOME/git/todo/tpush.sh')
    if has('win32')
        let l:path = tr(l:path, '\', '/')
    endif
    let l:cmd = "sh \"" . l:path . "\""
    execute "term " . l:cmd
endfunction

function! s:replace_start_with_today() abort
    call s:convert_wday_to_date()
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

function! SelectTaskPaperProject(is_inner, mode)
    let l:cur_lnum = line('.')
    let l:last_lnum = line('$')
    let l:proj_pattern = ':\s*\( @\|$\)'
    let l:start_lnum = l:cur_lnum
    while l:start_lnum > 1
        if getline(l:start_lnum) =~ l:proj_pattern | break | endif
        let l:start_lnum -= 1
    endwhile
    let l:end_lnum = l:start_lnum + 1
    while l:end_lnum <= l:last_lnum
        if getline(l:end_lnum) =~ l:proj_pattern
            let l:end_lnum -= 1
            break
        endif
        let l:end_lnum += 1
    endwhile
    if a:is_inner | let l:start_lnum += 1 | endif
    if l:start_lnum <= l:last_lnum && l:start_lnum <= l:end_lnum
        execute l:start_lnum
        if a:mode == 'block'
            execute "normal! \<C-v>"
            execute l:end_lnum
            normal! $
        else
            normal! V
            execute l:end_lnum
        endif
    endif
endfunction

function! s:compare_and_replace(date_str, today_str) abort
    if a:date_str <= a:today_str
        return "today"
    endif
    return a:date_str
endfunction

function! s:get_next_wday_date(target_wday) abort
    let l:current_wday = str2nr(strftime('%u'))
    let l:diff = a:target_wday - l:current_wday
    if l:diff <= 0
        let l:diff += 7
    endif
    return strftime('%Y-%m-%d', localtime() + l:diff * 86400)
endfunction

function! s:get_epoch(y, m, d) abort
  " Windows/a-Shell 両方で最もエラーが出にくい形式
  let l:target = printf('%04d-%02d-%02d 12:00:00', a:y, a:m, a:d)
  let l:epoch = strptime('%Y-%m-%d %H:%M:%S', l:target)
  if l:epoch <= 0
    " 万が一 strptime が失敗する場合のフォールバック (dateコマンド)
    return str2nr(system('date -d "' . l:target . '" +%s'))
  endif
  return l:epoch
endfunction

" 第n曜日計算 (@3fri など)
function! s:get_nth_wday_date(n, wday_idx) abort
  let l:y = str2nr(strftime('%Y'))
  let l:m = str2nr(strftime('%m')) + 1
  if l:m > 12 | let l:y += 1 | let l:m = 1 | endif

  let l:first_day_sec = s:get_epoch(l:y, l:m, 1)
  " 1日の曜日 (1:月..7:日)
  let l:first_wday = str2nr(strftime('%u', l:first_day_sec))
  " その月の最初の対象曜日の日
  let l:first_target_day = 1 + (a:wday_idx - l:first_wday + 7) % 7
  " 第n曜日の日
  let l:target_day = l:first_target_day + (a:n - 1) * 7
  
  " 1日からの差分秒を加算して日付を出す
  return strftime('%Y-%m-%d', l:first_day_sec + (l:target_day - 1) * 86400)
endfunction

" 翌月の日付計算（@day25- などの土日調整付き）
function! s:get_next_month_date(day, adjust) abort
  let l:y = str2nr(strftime('%Y'))
  let l:m = str2nr(strftime('%m')) + 1
  if l:m > 12 | let l:y += 1 | let l:m = 1 | endif

  " 翌月末日の算出 (翌々月1日の24時間前)
  let l:nm = l:m + 1
  let l:ny = l:y
  if l:nm > 12 | let l:ny += 1 | let l:nm = 1 | endif
  let l:last_day = str2nr(strftime('%d', s:get_epoch(l:ny, l:nm, 1) - 86400))

  let l:d = (a:day == 'last') ? l:last_day : str2nr(a:day)
  if l:d > l:last_day | let l:d = l:last_day | endif

  let l:target_time = s:get_epoch(l:y, l:m, l:d)
  let l:wday = str2nr(strftime('%u', l:target_time))

  " 土日調整 (6:土, 7:日)
  if a:adjust == '-'
    if l:wday == 6 | let l:target_time -= 86400 | elseif l:wday == 7 | let l:target_time -= 172800 | endif
  elseif a:adjust == '+'
    if l:wday == 6 | let l:target_time += 172800 | elseif l:wday == 7 | let l:target_time += 86400 | endif
  endif

  return strftime('%Y-%m-%d', l:target_time)
endfunction

function! s:convert_wday_to_date() abort
  let l:in_template = 0

  for l:lnum in range(1, line('$'))
    let l:line_content = getline(l:lnum)
    
    if l:line_content =~ '^[^ \t].*:\s*\( @\|$\)'
      let l:in_template = (l:line_content =~ '^Template:') ? 1 : 0
      continue
    endif

    if !l:in_template
      let l:old_line = l:line_content

      " --- A. 第n曜日 (@3fri) ---
      if l:line_content =~ '@[1-5]\%(mon\|tue\|wed\|thu\|fri\|sat\|sun\)'
        let l:line_content = substitute(l:line_content, '@\([1-5]\)\(mon\|tue\|wed\|thu\|fri\|sat\|sun\)', '\=s:helper_nth(submatch(1), submatch(2))', 'g')
      endif

      " --- B. 日付指定 (@day25-) ---
      if l:line_content =~ '@day\d\+'
        let l:line_content = substitute(l:line_content, '@day\(\d\+\)\([-+]\)\?', '\=s:helper_day(submatch(1), submatch(2))', 'g')
      endif

      " --- C. 末日 (@lastday-, @lastday+) ---
      " ここに記号のキャプチャを追加
      if l:line_content =~ '@lastday'
        let l:line_content = substitute(l:line_content, '@lastday\([-+]\)\?', '\=s:helper_last(submatch(1))', 'g')
      endif

      if l:line_content != l:old_line
        call setline(l:lnum, l:line_content)
      endif
    endif
  endfor
endfunction

function! s:helper_nth(n, w_str) abort
  let l:wday_map = {'mon':1, 'tue':2, 'wed':3, 'thu':4, 'fri':5, 'sat':6, 'sun':7}
  return '@start(' . s:get_nth_wday_date(str2nr(a:n), l:wday_map[a:w_str]) . ')'
endfunction

function! s:helper_day(day, adj) abort
  " a:adj には '-' や '+' が入るはず
  let l:date = s:get_next_month_date(a:day, a:adj)
  return '@start(' . l:date . ')'
endfunction

function! s:helper_last(adj) abort
  " 引数 a:adj に '-' や '+' が渡されるようになります
  return '@start(' . s:get_next_month_date('last', a:adj) . ')'
endfunction

command! Twday call s:convert_wday_to_date()
command! Ttoday call s:replace_start_with_today()

augroup TaskPaperAutoConvert
    autocmd!
augroup END

augroup MyTaskPaperSettings
    autocmd!
    autocmd BufRead,BufNewFile *.taskpaper {
        vnoremap <buffer> <silent> ip :<C-u>call SelectTaskPaperProject(1, 'line')<CR>
        onoremap <buffer> <silent> ip :<C-u>call SelectTaskPaperProject(1, 'line')<CR>
        vnoremap <buffer> <silent> ap :<C-u>call SelectTaskPaperProject(0, 'line')<CR>
        onoremap <buffer> <silent> ap :<C-u>call SelectTaskPaperProject(0, 'line')<CR>
        vnoremap <buffer> <silent> qp :<C-u>call SelectTaskPaperProject(0, 'block')<CR>
        onoremap <buffer> <silent> qp :<C-u>call SelectTaskPaperProject(0, 'block')<CR>
    }
augroup END

augroup TaskPaperAutoSync
    autocmd!
    autocmd BufWritePre *.taskpaper call s:convert_wday_to_date()
    autocmd BufWritePost *.taskpaper call s:sync_taskpaper()
    autocmd VimLeavePre  *.taskpaper call s:sync_taskpaper()
augroup END
" }}}
