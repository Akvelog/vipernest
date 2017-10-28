" Wmii-styled window split layout for vim. 

" Exit immediately if running already.
if exists("g:vrefsp_enabled") || &diff || &sp
    finish
endif

let g:vrefsp_enabled = 1

if v:version < 700
    finish
endif

function! Vrefsp_New(...)
    let l:filename = exists("a:1") ? a:1 : ""
    if Vrefsp_wincount() == 1
        exec "rightbelow vnew ".l:filename
        call Vrefsp_ResizeMaster()
    else
        let l:lastWinnr = Vrefsp_wincount()
        exec l:lastWinnr." wincmd w"
        exec "rightbelow new ".l:filename
    endif
endfunction

function! Vrefsp_ResizeMaster()
    let l:lastVisitedWinnr = tabpagewinnr(tabpagenr())
    wincmd =
    1 wincmd w
    if exists("g:vrefsp_masterViewWidth")
        if (type(g:vrefsp_masterViewWidth) == type(""))
            exec 'vertical resize '.( (str2nr(g:vrefsp_masterViewWidth) * &columns) / 100 )
        else
            exec 'vertical resize '.g:vrefsp_masterViewWidth
        endif
    endif
    exec l:lastVisitedWinnr." wincmd w"
endfunction

function Vrefsp_wincount()
    return tabpagewinnr(tabpagenr(), '$')
endfunction

com! -nargs=* -complete=file Vrefedit call Vrefsp_New("<args>")
com Vre Vrefedit
