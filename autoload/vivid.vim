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
" g:plugins = [[a, 1, 4], [b, 2, 5], [c, 3, 6],]
"              ^brackets = rows  ^numbers = columns
" | Name  | Remote Address                        | Install Path | Enabled |
" |-------+---------------------------------------+--------------+---------|
" | Vivid | https://github.com/axvr/Vivid.vim.git | Vivid        | 1       |
let s:plugins = [['Vivid', 'https://github.com/axvr/Vivid.vim', 'Vivid.vim', 1]]
let s:names   = { 'Vivid': 0, }
let s:next_location = 1
let s:install_dir = ''


" Set install directory automatically
if has('nvim')
    if !isdirectory($HOME . '/.config/nvim/bundle')
        call mkdir($HOME . '/.config/nvim/bundle')
    endif
    let s:install_dir = $HOME . '/.config/nvim/bundle'
else
    if !isdirectory($HOME . '/.vim/bundle')
        call mkdir($HOME . '/.vim/bundle')
    endif
    let s:install_dir = $HOME . '/.vim/bundle'
endif

" Allow manual setting of plugin directory by the user
function! vivid#set_install_dir(path) abort
    let s:install_dir = expand(a:path)
endfunction


" Add a plugin for Vivid to manage
" Example:
" call vivid#add('rhysd/clever-f.vim', {
"     \ 'name': 'Clever-f',
"     \ 'path': 'clever-f.vim',
"     \ 'enabled': '1',
"     \ } )
" Arguments: 'remote', { 'name': 'name', 'path': 'path', 'enabled': 'enabled' }
function! vivid#add(remote, ...) abort

    " Create remote path for plugin
    " TODO add functionality for other sources and methods
    if a:remote =~ '^https:\/\/.\+'
        let l:remote = a:remote
    elseif a:remote =~ '^http:\/\/.\+'
        let l:remote = a:remote
        let l:remote = substitute(l:remote, '^http:\/\/', 'https://', '')
    elseif a:remote =~ '^.\+\/.\+'
        let l:remote = 'https://github.com/' . a:remote . '.git'
    else
        echo "Remote address creation fail"
        return
    endif

    if a:0 == 1
        let l:info = a:1
    endif

    if a:0 == 1 && has_key(l:info, 'path')
        let l:path = l:info['path']
    else
        let l:path = l:remote
        let l:path = split(l:path, "/")
        let l:path = l:path[-1]
        " TODO maybe extend path to avoid same paths
    endif

    if a:0 == 1 && has_key(l:info, 'name')
        let l:name = l:info['name']
    else
        let l:name = l:remote
        let l:name = split(l:name, "/")
        let l:name = l:name[-1]
        let l:name = substitute(l:name, '\.', ';', '')
        let l:name = split(l:name, ";")
        let l:name = l:name[0]
    endif

    if a:0 == 1 && has_key(l:info, 'enabled')
        let l:enabled = l:info['enabled']
    else
        let l:enabled = 0
    endif

    " TODO check name (& path) don't already exist
    let l:plugin = [l:name, l:remote, l:path, l:enabled]
    call add(s:plugins, l:plugin)

    " TODO add name to dictionary
    let s:names[l:name] = s:next_location
    let s:next_location += 1

    return

endfunction


function! vivid#install(...) abort

endfunction


function! vivid#upgrade(...) abort

endfunction


function! vivid#enable(name) abort

endfunction


function! vivid#enable_local(name) abort

endfunction


