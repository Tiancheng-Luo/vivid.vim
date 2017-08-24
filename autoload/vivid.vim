" ==============================================================================
" Name:         Vivid.vim
" Author:       Alex Vear
" HomePage:     https://github.com/axvr/Vivid.vim
" Readme:       https://github.com/axvr/Vivid.vim/blob/master/README.md
" Version:      1.0.0
" ==============================================================================


if &compatible
    set nocompatible
    filetype off
endif


" Main list for Vivid to manage all plugins
" s:plugins = [[a, 1, 4], [b, 2, 5], [c, 3, 6],]
"              ^brackets = rows  ^numbers = columns
" | Name  | Remote Address                        | Install Path | Enabled |
" |-------+---------------------------------------+--------------+---------|
" | Vivid | https://github.com/axvr/Vivid.vim.git | Vivid        | 1       |
let s:plugins = [['Vivid', 'https://git::@github.com/axvr/Vivid.vim', 'Vivid.vim', 1]]
" Dictionary containing locations of plugins in the list (for quickly finding
" a specific plugin, without requiring searching every item of the list)
let s:names   = { 'Vivid': 0, }
let s:next_location = 1
let s:install_dir = ''


" Set install directory automatically
let s:nvim_path = $HOME . '/.config/nvim/pack/vivid/opt'
let s:vim_path  = $HOME . '/.vim/pack/vivid/opt'
" TODO add more options for different types of vim
if has('nvim')
    if !isdirectory(s:nvim_path)
        call mkdir(s:nvim_path, 'p')
    endif
    let s:install_dir = s:nvim_path
else
    if !isdirectory(s:vim_path)
        call mkdir(s:vim_path, 'p')
    endif
    let s:install_dir = s:vim_path
endif

" Allow manual setting of plugin directory by the user
"function! vivid#set_install_dir(path) abort
"    let s:install_dir = expand(a:path)
"endfunction


" Add a plugin for Vivid to manage
" Example:
" call vivid#add('rhysd/clever-f.vim', {
"     \ 'name': 'Clever-f',
"     \ 'path': 'clever-f.vim',
"     \ 'enabled': 1,
"     \ } )
" Arguments: 'remote', { 'name': 'name', 'path': 'path', 'enabled': 'enabled' }
function! vivid#add(remote, ...) abort

    " Create remote path for plugin
    " TODO add functionality for other sources and methods
    " TODO windows shellescape()
    if a:remote =~ '^https:\/\/.\+'
        let l:remote = a:remote
    elseif a:remote =~ '^http:\/\/.\+'
        let l:remote = a:remote
        let l:remote = substitute(l:remote, '^http:\/\/', 'https://', '')
    elseif a:remote =~ '^.\+\/.\+'
        let l:remote = 'https://git::@github.com/' . a:remote . '.git'
    else
        echo "Remote address creation fail:" a:remote
        return
    endif

    " If extra info is given create a new dictionary for it
    if a:0 == 1
        let l:info = a:1
    endif

    " Create the path from the remote address (unless one was given)
    if a:0 == 1 && has_key(l:info, 'path')
        let l:path = l:info['path']
    else
        let l:path = l:remote
        let l:path = split(l:path, "/")
        let l:path = l:path[-1]
        let l:path = substitute(l:path, '\.git$', '', '')
        " TODO maybe extend path to avoid path collision
    endif

    " Create the name from the remote address (unless one was given)
    if a:0 == 1 && has_key(l:info, 'name')
        let l:name = l:info['name']
    else
        let l:name = l:remote
        let l:name = split(l:name, "/")
        let l:name = l:name[-1]
        " for some unknown reason, split() does not work on '.'
        let l:name = substitute(l:name, '\.', ';', '')
        let l:name = split(l:name, ";")
        let l:name = l:name[0]
    endif

    " Default the auto-enabled to false (unless explicitly stated otherwise)
    if a:0 == 1 && has_key(l:info, 'enabled')
        let l:enabled = l:info['enabled']
    else
        let l:enabled = 0
    endif


    " Check that the same plugin has not already been added to Vivid
    if !has_key(s:names, l:name)
        " Add plugin to the (2D) list
        let l:plugin = [l:name, l:remote, l:path, l:enabled]
        call add(s:plugins, l:plugin)
        " Add plugin to the s:names dictionary to find the info quickly
        let s:names[l:name] = s:next_location
        let s:next_location += 1
    endif

    if l:enabled == 1
        call vivid#enable(l:name)
    endif

    return

endfunction


" Install plugins
" TODO async download
" TODO more validation
" TODO windows compatible
function! vivid#install(...) abort
    let l:echo_message = "Vivid: Plugin install -"
    echomsg l:echo_message "START"
    if a:0 != 0
        for l:plugin in a:000
            if has_key(s:names, l:plugin)
                let l:index = get(s:names, l:plugin, '-1')
                if l:index != -1
                    let l:install_path = s:install_dir . "/" .
                                \ s:plugins[l:index][2]
                    if !isdirectory(l:install_path)
                        let l:cmd = "git clone " . s:plugins[l:index][1] .
                                    \ " " . l:install_path
                        let l:clone = system(l:cmd)
                        echomsg l:echo_message "Installed:"
                                    \ s:plugins[l:index][0]
                    else
                        echomsg l:echo_message "Skipped:  "
                                    \ s:plugins[l:index][0]
                    endif
                endif
            else
                echomsg l:echo_message "Failed:   " l:plugin
            endif
        endfor
    else
        let l:index = 0
        for l:plugin in s:plugins
            let l:install_path = s:install_dir . "/" . l:plugin[2]
            if !isdirectory(l:install_path)
                let l:cmd = "git clone " . l:plugin[1] . " " . l:install_path
                let l:clone = system(l:cmd)
                echomsg l:echo_message "Installed:" l:plugin[0]
            else
                echomsg l:echo_message "Skipped:  " l:plugin[0]
            endif
            let l:index += 1
        endfor
    endif
    echomsg l:echo_message "DONE"
endfunction


" Upgrade plugins (TODO async download)
function! vivid#upgrade(...) abort
    if a:0 != 0
        for l:plugin in a:000
            if has_key(s:names, l:plugin)
                let l:index = get(s:names, l:plugin, '-1')
                if l:index != -1
                    " TODO upgrade plugin
                    echo s:plugins[l:index][1]
                endif
            endif
        endfor
    else
        let l:index = 0
        for l:plugin in s:plugins
            " TODO upgrade plugin
            echo l:plugin[1]

            let l:index += 1
        endfor
    endif
    echo "Vivid: Plugin upgrade - DONE"
endfunction


function! vivid#enable(...) abort
    if a:0 != 0
        for l:plugin in a:000
            if has_key(s:names, l:plugin)
                let l:index = get(s:names, l:plugin, '-1')
                if l:index != -1
                    let s:plugins[l:index][3] = 1
                    execute 'packadd ' . s:plugins[l:index][2]
                endif
            endif
        endfor
    else
        let l:index = 0
        for l:plugin in s:plugins
            if l:plugin[3] != 1
                let s:plugins[l:index][3] = 1
                execute 'packadd ' . l:plugin[2]
                let l:index += 1
            endif
        endfor
    endif
endfunction


"function! vivid#clean(...) abort
"
"endfunction


" vim: set ts=4 sw=4 tw=80 et :
