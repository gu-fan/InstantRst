" instantRst.vim
" Got the solution in python way from suan's instant-markdown
" https://github.com/suan/instant-markdown-d

if !executable('curl')
    echoe "[InstantRst] curl is required. Stop"
    finish
endif

if !exists('g:instant_rst_slow')
    let g:instant_rst_slow = 0
endif

if !exists('g:instant_rst_forever')
    let g:instant_rst_forever = 0
endif

if !exists('g:instant_rst_browser')
    let g:instant_rst_browser = ''
endif

if !exists('g:instant_rst_port')
    let g:instant_rst_port = 5676
endif

if !exists('g:instant_rst_bind_scroll')
    let g:instant_rst_bind_scroll = 1
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

function! s:startDaemon(file) "{{{
    if g:_instant_rst_daemon_started == 0
        let args_browser = g:instant_rst_browser != '' ? 
                    \ ' -b '.g:instant_rst_browser : ''
        let args_port = g:instant_rst_port != 5676 ? 
                    \ ' -p '.g:instant_rst_port : ''
        let args_file = a:file != '' ? 
                    \ ' -f '.a:file : ''

        let  cmd = "instantRst "
                    \.args_browser
                    \.args_port
                    \.args_file
                    \.' &>/dev/null'
                    \.' &'
        call s:system(cmd)
        let g:_instant_rst_daemon_started = 1
    endif
endfun "}}}

function! s:killDaemon()
    if g:_instant_rst_daemon_started == 1
        call s:system("curl -s -X DELETE http://localhost:".g:instant_rst_port." / &>/dev/null &")
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
    let cmd = "curl -d 'file=". b:ir_tmpfile ."' -d 'p=".p."'  http://localhost:".g:instant_rst_port." &>/dev/null &"
    " >>> let cmd = 'curl -d name=hello http://localhost:'.g:instant_rst_port
    " >>> call s:system(cmd)
    call s:system(cmd)
endfun

fun! s:scroll() "{{{
    let p = string(str2float(line('.')) / line('$'))

    if exists('b:scroll_pos') && b:scroll_pos == p
        return
    endif

    let b:scroll_pos = p

    let cmd = "curl -d p='".p."' http://localhost:".g:instant_rst_port." &>/dev/null &"
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

fu! s:cleanUp(bang)
    if a:bang == '!'
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
    echohl ModeMsg
    echon "[InstantRst]"
    echohl Normal
    echon " Preview buffer at http://localhost:".g:instant_rst_port

    call s:startDaemon(expand('%:p'))
    call s:pushBuffer(bufnr('%'))
    call s:refreshView()

    if a:bang == '!' ||  g:instant_rst_forever == 1
        " Add a always preview rst mode
        aug instant-rst
            au!
            if g:instant_rst_slow
                au CursorHold,BufWrite,InsertLeave *.rst call s:temperedRefresh()
            else
                au CursorHold,CursorHoldI,CursorMoved,CursorMovedI *.rst call s:temperedRefresh()
            endif
            if g:instant_rst_bind_scroll
                au CursorHold,CursorHoldI,CursorMoved,CursorMovedI *.rst call s:scroll()
            endif
            au BufWinEnter,WinEnter *.rst call s:refreshView()
            au VimLeave * call s:cleanUp('!')
        aug END
    else
        aug instant-rst
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
