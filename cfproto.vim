"if exists("loaded_cFuncProto")
    "finish
"endif
"let loaded_cFuncProto = 1

if (!exists('g:cfproto_alternateSearchPath'))
    let b:alternateFile = findfile('.clang_complete', '.;')
    if (b:alternateFile != '')
        let b:alternatePaths = readfile(b:alternateFile)
        let g:cfproto_alternateSearchPath = ''
        for b:alternatePath in b:alternatePaths
            let b:alternatePath = substitute(b:alternatePath, '^-I', '', '')
            let g:cfproto_alternateSearchPath .= (b:alternatePath.'/*.h ')
        endfor
    else
        let g:cfproto_alternateSearchPath = ''
    endif
endif

let g:cfproto_searchPath = g:cfproto_alternateSearchPath.' *.h *.c'

if g:cfproto_use_std_inc == 1
    if (exists('g:cfproto_std_inc_path'))
        let g:cfproto_searchPath = g:cfproto_searchPath.g:cfproto_std_inc_path.'*.h '
    else
        let g:cfproto_searchPath = g:cfproto_searchPath.'/usr/include/*.h /usr/local/include/*.h '
    endif
endif

if (!exists('g:cfproto_options'))
    let g:cfproto_options = '--c-kinds=fp --fields=+S-kfs -f- --recurse=yes '
endif

command! -nargs=0 CFuncParseCtags call EchoPrototype()

function CFParseCtags()
    let l:file_self = expand('%t')
    let l:ctags_cmd = 'ctags '.g:cfproto_options.' '.g:cfproto_searchPath.' '.l:file_self
    let l:cmd_output = system(l:ctags_cmd)
    let l:match_funcName = expand('<cword>')

    if l:cmd_output == ''
        return 'No tags available. Command='.l:ctags_cmd
    endif

    let l:cmd_outputList = split(l:cmd_output, "\n")
    for l:cmd_outputLine in l:cmd_outputList
        let l:parseInput = split(l:cmd_outputLine, "\t")
        if l:parseInput[0] == l:match_funcName
            let l:ret_filename = l:parseInput[1]
            let l:ret_excmd = substitute(l:parseInput[2], '\/', '', 'g')
            let l:ret_excmd = substitute(l:ret_excmd, '\^', '', 'g')
            let l:arr_excmd = split(l:ret_excmd, ' ')
            let l:ret_protostr = ''
            let l:stars = ''
            for l:elt_excmd in l:arr_excmd
                if match(l:elt_excmd, '^\**'.l:parseInput[0].'\s*(') == 0
                    let l:staridx = 0
                    while (l:elt_excmd[l:staridx] == '*')
                        let l:stars .= '*'
                        let l:staridx = l:staridx + 1
                    endwhile
                    break
                endif
                let l:ret_protostr .= l:elt_excmd.' '
            endfor
            let l:ret_protostr .= l:stars
            let l:ret_protostr .= substitute(l:parseInput[3], 'signature:', l:parseInput[0], '')
            return l:ret_filename.': '.l:ret_protostr
        endif
    endfor
    return "No function prototype"
endfunction

function EchoPrototype()
    let l:ret = CFParseCtags()
    echo l:ret
endfunction
