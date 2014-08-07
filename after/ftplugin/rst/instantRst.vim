" instantRst.vim
" Got the solution in python way from suan's instant-markdown
" https://github.com/suan/instant-markdown-d

if !exists('g:instant_rst_slow')
    let g:instant_rst_slow = 0
endif

if !exists('g:instant_rst_browser')
    let g:instant_rst_browser = ''
endif

if !exists('g:_instant_rst_daemon_started')
    let g:_instant_rst_daemon_started = 0
endif

if !exists('s:autoload_path')
    let s:autoload_path = expand('<sfile>:p:h')
endif

if !exists('s:buffers')
    let s:buffers = {}
endif
fun! s:system(cmd) abort
    if exists("*vimproc#system")
        call vimproc#system(cmd)
    else
        call system(cmd)
    endif
    <`0`>
endfun

function! s:startDaemon()
    if g:_instant_rst_daemon_started == 0
        let  cmd = "python ".s:autoload_path."/instantRst.py &>/dev/null &"
        call vimproc#system(cmd)
        let g:_instant_rst_daemon_started = 1
        if !empty(g:instant_rst_browser)
            sil! exe '!'.g:instant_rst_browser.' http://localhost:5676/'
        endif
    endif

endfu

function! s:killDaemon()
    if g:_instant_rst_daemon_started == 1
        call vimproc#system("curl -s -X DELETE http://localhost:5676 / &>/dev/null &")
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
    let cmd = "curl -d 'file=". b:ir_tmpfile ."' http://localhost:5676 &>/dev/null &"
    " >>> let cmd = 'curl -d name=hello http://localhost:5676'
    " >>> call vimproc#system(cmd)
    call vimproc#system(cmd)
endfun

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
    call remove(s:buffers, a:bufnr)
endfu

fu! s:cleanUp()
    call s:popBuffer(bufnr('%'))

    if len(s:buffers) == 0
        call s:killDaemon()
    endif
  
    if filereadable(b:ir_tmpfile)
        call delete(b:ir_tmpfile)
    endif

    au! instant-rst * <buffer>
endfu


fu! s:preview(bang)
    echohl ModeMsg
    echon "[InstantRst]"
    echohl Normal
    echon " Preview buffer at http://localhost:5676/"

    call s:startDaemon()
    call s:pushBuffer(bufnr('%'))
    call s:refreshView()

    if a:bang == '!'
        " Add a always preview rst mode
        aug instant-rst
            if g:instant_rst_slow
                au WinEnter,CursorHold,BufWrite,InsertLeave *.rst call s:temperedRefresh()
            else
                au WinEnter,CursorHold,CursorHoldI,CursorMoved,CursorMovedI *.rst call s:temperedRefresh()
            endif
            au VimLeave <buffer> call s:cleanUp()
        aug END
    else
        aug instant-rst
            if g:instant_rst_slow
                au CursorHold,BufWrite,InsertLeave <buffer> call s:temperedRefresh()
            else
                au CursorHold,CursorHoldI,CursorMoved,CursorMovedI <buffer> call s:temperedRefresh()
            endif
            au BufWinLeave <buffer> call s:cleanUp()
        aug END
    endif
endfu


command! -bang -buffer InstantRst call s:preview('<bang>')
command! -buffer StopInstantRst call s:cleanUp()
