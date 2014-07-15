" instantRst.vim
" Got the solution in python way from suan's instant-markdown
" https://github.com/suan/instant-markdown-d

if !exists('g:instant_rst_slow')
    let g:instant_rst_slow = 0
endif

if !exists('g:instant_rst_browser')
    let g:instant_rst_browser = ''
endif

let s:autoload_path = expand('<sfile>:p:h')
let s:daemon_started = 0
let s:buffers = {}

function! s:startDaemon()
    if !s:daemon_started
        let  cmd = "python ".s:autoload_path."/instantRst.py &>/dev/null &"
        call system(cmd)
        let s:daemon_started = 1
        if !empty(g:instant_rst_browser)
            sil! exe '!'.g:instant_rst_browser.' http://localhost:5676/'
        endif
    endif

endfu

function! s:killDaemon()
    if s:daemon_started
        call system("curl -s -X DELETE http://localhost:5676 / &>/dev/null &")
        let s:daemon_started = 0
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
    call system(cmd)
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


fu! s:preview()
    echohl ModeMsg
    echon "[InstantRst]"
    echohl Normal
    echon " Preview buffer at http://localhost:5676/"

    call s:startDaemon()
    call s:pushBuffer(bufnr('%'))
    call s:refreshView()

    aug instant-rst
        if g:instant_rst_slow
            au CursorHold,BufWrite,InsertLeave <buffer> call s:temperedRefresh()
        else
            au CursorHold,CursorHoldI,CursorMoved,CursorMovedI <buffer> call s:temperedRefresh()
        endif
        au BufWinLeave <buffer> call s:cleanUp()
    aug END
endfu


command! -buffer InstantRst call s:preview()
command! -buffer StopInstantRst call s:cleanUp()
