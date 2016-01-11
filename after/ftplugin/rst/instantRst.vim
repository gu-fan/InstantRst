" instantRst.vim
" Got the solution in python way from suan's instant-markdown
" https://github.com/suan/instant-markdown-d


if !exists('g:instant_rst_slow')
    let g:instant_rst_slow = 0
endif

if !exists('g:instant_rst_forever')
    let g:instant_rst_forever = 0
endif

if !exists('g:instant_rst_browser')
    let g:instant_rst_browser = ''
endif

if !exists('g:instant_rst_static')
    let g:instant_rst_static = ''
endif

if !exists('g:instant_rst_template')
    let g:instant_rst_template = ''
endif

if !exists('g:instant_rst_port')
    let g:instant_rst_port = 5676
endif

if !exists('g:instant_rst_bind_scroll')
    let g:instant_rst_bind_scroll = 1
endif

if !exists('g:instant_rst_localhost_only')
    let g:instant_rst_localhost_only = 0
endif

if !exists('g:instant_rst_additional_dirs')
    let g:instant_rst_additional_dirs = []
endif

if !exists('g:_instant_rst_daemon_started')
    let g:_instant_rst_daemon_started = 0
endif

if !exists('s:buffers')
    let s:buffers = {}
endif
fun! s:system(cmd) abort "{{{
    if exists("*vimproc#system")
        call vimproc#system(a:cmd)
    else
        call system(a:cmd)
    endif
endfun "}}}

" XXX:Avoid using socket host name, for sake of the risk of a PC have multiple
" LAN IP which will causing mistake.
" if has('python') && g:instant_rst_localhost_only != 1
"     py import socket,vim
"     py host = socket.gethostbyname(socket.gethostname())
"     py vim.command('let s:host= "' + host + '"' )
" else
"     let s:host = 'localhost'
" endif

let s:host = 'localhost'

function! s:startDaemon(file) "{{{
    if !executable('instantRst')
        echoe "[InstantRst] intant-rst.py is required."
        echoe "sudo pip install https://github.com/Rykka/instant-rst.py/archive/master.zip"
        return -1
    endif

    if !executable('curl')
        echoe "[InstantRst] curl is required."
        echoe "sudo apt-get install curl"
        return -1
    endif
    if g:_instant_rst_daemon_started == 0
        let args_browser = g:instant_rst_browser != '' ? 
                    \ ' -b '.g:instant_rst_browser : ''
        let args_port = g:instant_rst_port != 5676 ? 
                    \ ' -p '.g:instant_rst_port : ''
        let args_static = g:instant_rst_static != '' ? 
                    \ ' -s '.g:instant_rst_static : ''
        let args_template = g:instant_rst_template != '' ? 
                    \ ' -t '.g:instant_rst_template : ''
        let args_file = a:file != '' ? 
                    \ ' -f '.substitute(a:file, ' ', '\\ ', 'g') : ''
        let args_local = g:instant_rst_localhost_only == 1 ? 
                    \ ' -l ' : ''
        let args_additional_dirs = ''

        for directory in g:instant_rst_additional_dirs
            let args_additional_dirs .= ' -d '.directory
        endfor

        let  cmd = "instantRst "
                    \.args_browser
                    \.args_port
                    \.args_file
                    \.args_static
                    \.args_template
                    \.args_local
                    \.args_additional_dirs
                    \.' &>/dev/null'
                    \.' &'
        call s:system(cmd)
        let g:_instant_rst_daemon_started = 1
    endif
endfun "}}}

function! s:killDaemon()
    if g:_instant_rst_daemon_started == 1
        call s:system("curl -s -X DELETE http://" . s:host .  ":".g:instant_rst_port." / &>/dev/null &")
        let g:_instant_rst_daemon_started = 0
    endif
endfu
fun! s:updateTmpFile(bufname)
    if !exists("b:ir_tmpfile")
        let b:ir_tmpfile = tempname()
    endif
    let buf = getbufline(a:bufname, 1, "$")
    call writefile(buf, b:ir_tmpfile)
endfun
 
fun! s:refreshView()
    call s:updateTmpFile(bufnr('%'))
    let p = string(str2float(line('.')) / line('$'))
    let dir = expand('%:p:h')
    let cmd = "curl -d 'file=". b:ir_tmpfile ."' -d 'p=".p."' -d 'dir=".dir."'  http://" . s:host . ":".g:instant_rst_port." &>/dev/null &"
    " >>> let cmd = 'curl -d name=hello http://' . s:host . ':'.g:instant_rst_port
    " >>> call s:system(cmd)
    call s:system(cmd)
endfun

fun! s:scroll() "{{{
    let p = string(str2float(line('.')) / line('$'))

    if exists('b:scroll_pos') && b:scroll_pos == p
        return
    endif

    let b:scroll_pos = p

    let cmd = "curl -d p='".p."' http://" . s:host . ":".g:instant_rst_port." &>/dev/null &"
    call s:system(cmd)

endfun "}}}

fu! s:temperedRefresh()
    if !exists('b:changedtickLast')
        let b:changedtickLast = b:changedtick
        call s:refreshView()
    elseif b:changedtickLast != b:changedtick
        let b:changedtickLast = b:changedtick
        call s:refreshView()
    endif
endfu


function! s:pushBuffer(bufnr)
    let s:buffers[a:bufnr] = 1
endfu

function! s:popBuffer(bufnr)
    sil! call remove(s:buffers, a:bufnr)
endfu

fu! s:cleanUp(...)
    let bang = get(a:000, 0 , '')
    if bang == '!'
        let s:buffers = {}
        call s:killDaemon()
    else
        call s:popBuffer(bufnr('%'))

        if len(s:buffers) == 0
            call s:killDaemon()
        endif
    endif
  
    if exists("b:ir_tmpfile") && filereadable(b:ir_tmpfile)
        call delete(b:ir_tmpfile)
    endif

    if exists("#instant-rst")
        au! instant-rst * <buffer>
    endif
endfu



fu! s:preview(bang)

    if s:startDaemon(expand('%:p')) == -1
        return
    endif
    call s:pushBuffer(bufnr('%'))
    call s:refreshView()

    echohl ModeMsg
    echon "[InstantRst]"
    echohl Normal
    echon " Preview buffer at http://" . s:host . ":".g:instant_rst_port

    if a:bang == '!' ||  g:instant_rst_forever == 1
        " Add a always preview rst mode
        aug instant-rst
            sil! au! 
            if g:instant_rst_slow
                au CursorHold,BufWrite,InsertLeave <buffer>,*.rst call s:temperedRefresh()
            else
                au CursorHold,CursorHoldI,CursorMoved,CursorMovedI <buffer>,*.rst call s:temperedRefresh()
            endif
            if g:instant_rst_bind_scroll
                au CursorHold,CursorHoldI,CursorMoved,CursorMovedI <buffer>,*.rst call s:scroll()
            endif
            au BufWinEnter,WinEnter <buffer>,*.rst call s:refreshView()
            au VimLeave * call s:cleanUp('!')
        aug END
    else
        aug instant-rst
            sil! au! <buffer>
            if g:instant_rst_slow
                au CursorHold,BufWrite,InsertLeave <buffer> call s:temperedRefresh()
            else
                au CursorHold,CursorHoldI,CursorMoved,CursorMovedI <buffer> call s:temperedRefresh()
            endif
            if g:instant_rst_bind_scroll
                au CursorHold,CursorHoldI,CursorMoved,CursorMovedI <buffer> call s:scroll()
            endif
            au BufWinEnter,WinEnter <buffer> call s:refreshView()
            au BufWinLeave <buffer> call s:cleanUp()
        aug END
    endif
endfu

command! -bang -buffer InstantRst call s:preview('<bang>')
command! -bang -buffer StopInstantRst call s:cleanUp('<bang>')
