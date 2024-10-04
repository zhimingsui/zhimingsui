function! myspacevim#before() abort
    " 关闭鼠标
    set mouse=

    " 设置默认搜索工具
    let profile = SpaceVim#mapping#search#getprofile('rg')
    let default_opt = profile.default_opts + ['--no-ignore-vcs']
    call SpaceVim#mapping#search#profile({'rg' : {'default_opts' : default_opt}})

    lua << EOF
    local opt = requires('spacevim.opt')
    opt.enable_projects_cache = false
    opt.enable_statusline_mode = true
EOF

endfunction

function! myspacevim#after() abort
    " you can remove key binding in bootstrap_after function
    " iunmap kj
endfunction

" function! s:test_section() abort
  " return 'ok'
" endfunction
" call SpaceVim#layers#core#statusline#register_sections('test', function('s:test_section'))

