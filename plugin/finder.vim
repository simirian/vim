" simple file finder by simirian

if exists("g:loaded_finder")
    finish
endif
let g:loaded_finder = 1

let g:finder_cmd = "find . | grep -v '/\\.'"
let g:finder_select = "edit"

let s:oldinput = ""
let s:selected = 0
let s:job = v:null

sign define finder_selected text=>

function! s:JobDone(channel)
    let text = [""]
    while ch_status(a:channel, {"part": "out"}) == "buffered"
        let text += [ch_read(a:channel)]
    endwhile
    let s:selected = 0
    call sign_unplace("finder")
    call deletebufline("finder", 2, "$")
    call appendbufline("finder", 1, text)
    if len(text) > 1
        let s:selected = 3
        call sign_place(0, "finder", "finder_selected", "finder", {"lnum": s:selected})
    endif
endfunction

function! s:FindUpdate()
    let input = getbufline("finder", 1)[0]
    if type(s:job) == v:t_job
        job_stop(s:job)
    endif
    let cmd = g:finder_cmd .. " | grep " .. shellescape(input)
    if (&ignorecase && &smartcase && input ==# tolower(input)) || (&ignorecase && !&smartcase)
        let cmd = g:finder_cmd .. " | grep -i " .. shellescape(input)
    endif
    call job_start(["sh", "-c", cmd], {"close_cb": function("s:JobDone")})
endfunction

function! s:FindSelect()
    let s:selected = s:selected < 3 ? 3 : s:selected
    let s:selected = s:selected > line("$") ? line("$") : s:selected
    let line = getbufline("finder", s:selected)[0]
    buffer #
    exe g:finder_select .. " " .. line
endfunction

function! s:FindNext()
    let s:selected += 1
    let s:selected = s:selected > line("$") ? 3 : s:selected
    call sign_unplace("finder")
    call sign_place(0, "finder", "finder_selected", "finder", {"lnum": s:selected})
endfunction

function! s:FindPrev()
    let s:selected -= 1
    let s:selected = s:selected < 3 ? line("$") : s:selected
    call sign_unplace("finder")
    call sign_place(0, "finder", "finder_selected", "finder", {"lnum": s:selected})
endfunction

function! s:BufNew()
    buffer finder
    set bt=nofile bh=hide noswf nobl
    inoremap <buffer> <cr> <cmd>call <sid>FindSelect()<cr>
    inoremap <buffer> <C-j> <cmd>call <sid>FindNext()<cr>
    inoremap <buffer> <C-k> <cmd>call <sid>FindPrev()<cr>
endfunction

function! s:BufEnter()
    let w:oldscl = &scl
    set scl=yes
    call feedkeys("ggA", "n")
    call s:FindUpdate()
endfunction

function! s:BufLeave()
    let &scl = w:oldscl
    unlet w:oldscl
    stopinsert
endfunction

function! s:TextChangedI()
    let input = getbufline("finder", 1)[0]
    if s:oldinput != input
        call s:FindUpdate()
        let s:oldinput = input
    endif
endfunction

augroup Finder
    au BufNew       finder call <sid>BufNew()
    au BufEnter     finder call <sid>BufEnter()
    au BufLeave     finder call <sid>BufLeave()
    au InsertLeave  finder buffer #
    au TextChangedI finder call <sid>TextChangedI()
augroup END
