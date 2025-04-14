" simple file finder by simirian

if exists("g:loaded_finder")
    finish
endif
let g:loaded_finder = 1

sign define finder_selected text=>

function! s:BufJobDone(buf, channel)
    let text = [""]
    while ch_status(a:channel, {"part": "out"}) == "buffered"
        let text += [ch_read(a:channel)]
    endwhile
    call setbufvar(a:buf, "finder_selected", 0)
    call sign_unplace("finder")
    call deletebufline(a:buf, 2, "$")
    call appendbufline(a:buf, 1, text)
    if len(text) > 1
        call setbufvar(a:buf, "finder_selected", 3)
        call sign_place(0, "finder", "finder_selected", a:buf, {"lnum": 3})
    endif
endfunction

function! s:JobDone(buf)
    return {channel -> s:BufJobDone(a:buf, channel)}
endfunction

function! s:FindUpdate(buf)
    let input = getbufline(a:buf, 1)[0]
    let job = getbufvar(a:buf, "finder_job")
    if type(job) == v:t_job
        call job_stop(job)
    endif
    let cmd = getbufvar(a:buf, "finder_cmd") .. " | grep " .. shellescape(input)
    if getbufvar(a:buf, "&ignorecase")
        if getbufvar(a:buf, "&smartcase") && input ==# tolower(input) || !getbufvar(a:buf, "&smartcase")
            let cmd = getbufvar(a:buf, "finder_cmd") .. " | grep -i " .. shellescape(input)
        endif
    endif
    let job = job_start(["sh", "-c", cmd], {"close_cb": s:JobDone(a:buf)})
    call setbufvar(a:buf, "finder_job", job)
endfunction

function! s:FindSelect(buf)
    let selected = getbufvar(a:buf, "finder_selected")
    if selected < 3
        return
    endif
    let line = getbufline(a:buf, selected)[0]
    exe getbufvar(a:buf, "finder_select") .. " " .. line
endfunction

function! s:FindNext(buf)
    let selected = getbufvar(a:buf, "finder_selected")
    let selected += 1
    let selected = selected > line("$") ? 3 : selected
    call setbufvar(a:buf, "finder_selected", selected)
    call sign_unplace("finder")
    call sign_place(0, "finder", "finder_selected", a:buf, {"lnum": selected})
endfunction

function! s:FindPrev(buf)
    let selected = getbufvar(a:buf, "finder_selected")
    let selected -= 1
    let selected = selected < 3 ? line("$") : selected
    call setbufvar(a:buf, "finder_selected", selected)
    call sign_unplace("finder")
    call sign_place(0, "finder", "finder_selected", a:buf, {"lnum": selected})
endfunction

function! s:Init(buf)
    let bufname = bufname(a:buf)
    let mode = bufname[match(bufname, '\(find:\/\/\)\@<=[^\/]*'):]
    let cmd = "find . | grep -v '/\\.'"
    let select = "edit"
    if mode == "all"
        let cmd = "find ."
    elseif mode == "help"
        let files = join(globpath(&runtimepath, "**/doc/tags", 1, 1), " ")
        let cmd = "grep -ohe '^[^[:space:]]*' " .. files
        let finder_select = "help"
    elseif mode == "git"
        let cmd = "git ls-tree -r $(git branch --show) --name-only"
    endif
    call setbufvar(a:buf, "finder_cmd", cmd)
    call setbufvar(a:buf, "finder_select", select)
endfunction

" find://mode

function! s:BufEnter()
    if &ft != "finder"
        set bt=nofile bh=hide ft=finder noswf nobl
        let bufnr = bufnr()
        exe "inoremap <buffer> <cr> <cmd>call <sid>FindSelect(" .. bufnr .. ")<cr>"
        exe "inoremap <buffer> <C-j> <cmd>call <sid>FindNext(" .. bufnr .. ")<cr>"
        exe "inoremap <buffer> <C-k> <cmd>call <sid>FindPrev(" .. bufnr .. ")<cr>"
        call s:Init(bufnr)
    endif
    let w:oldscl = &scl
    set scl=yes
    call feedkeys("ggA", "n")
    call s:FindUpdate(bufnr())
endfunction

" TODO scl setting bug
function! s:BufLeave()
    let &scl = w:oldscl
    unlet w:oldscl
    stopinsert
endfunction

function! s:TextChangedI()
    let input = getbufline(bufnr(), 1)[0]
    if input != getbufvar(bufnr(), "finder_oldinput")
        call s:FindUpdate(bufnr())
        call setbufvar(bufnr(), "finder_oldinput", input)
    endif
endfunction

augroup Finder
    au!
    au BufEnter     find://* call <sid>BufEnter()
    au BufLeave     find://* call <sid>BufLeave()
    au InsertLeave  find://* buffer #
    au TextChangedI find://* call <sid>TextChangedI()
augroup END
