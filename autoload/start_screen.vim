function! start_screen#show(blocks)
    " Clear the screen and open a blank buffer
    enew
    " Set buffer options
    setlocal buftype=nofile
    setlocal bufhidden=hide
    setlocal noswapfile
    setlocal nobuflisted
    setlocal nonumber
    setlocal norelativenumber
    setlocal signcolumn=no

    let l:formatted_lines = []
    let l:headers = []

    for l:block in a:blocks
        " Add title if it exists
        if has_key(l:block, 'title')
            call add(l:formatted_lines, l:block.title)
            call add(l:headers, l:block.title)
        endif

        " Process items in the block to find optimal spacing
        if has_key(l:block, 'items') && !empty(l:block.items)
            let l:max_key = 0
            let l:max_desc = 0
            for l:item in l:block.items
                let l:k = ""
                let l:d = ""
                if type(l:item) == v:t_list
                    let l:k = get(l:item, 0, "")
                    let l:d = get(l:item, 1, "")
                elseif type(l:item) == v:t_dict
                    let l:k = get(l:item, "shortcut", "")
                    let l:d = get(l:item, "description", "")
                endif
                if strlen(l:k) > l:max_key | let l:max_key = strlen(l:k) | endif
                if strlen(l:d) > l:max_desc | let l:max_desc = strlen(l:d) | endif
            endfor

            " Format each item using the block's specific max widths
            for l:item in l:block.items
                let l:key  = ""
                let l:desc = ""
                let l:cmd  = ""

                if type(l:item) == v:t_list
                    let l:key  = get(l:item, 0, "")
                    let l:desc = get(l:item, 1, "")
                    let l:cmd  = get(l:item, 2, "")
                elseif type(l:item) == v:t_dict
                    let l:key  = get(l:item, "shortcut", "")
                    let l:desc = get(l:item, "description", "")
                    let l:cmd  = get(l:item, "command", "")
                endif
                
                let l:line = ""
                if l:key != ""
                    let l:line .= printf("%-" . l:max_key . "s  ", l:key)
                endif
                
                if l:cmd != ""
                    let l:line .= printf("%-" . l:max_desc . "s  %s", l:desc, l:cmd)
                else
                    let l:line .= l:desc
                endif
                
                let l:line = substitute(l:line, '\s\+$', '', '')
                call add(l:formatted_lines, l:line)
            endfor
        endif

        " Add separator between blocks
        call add(l:formatted_lines, "")
    endfor

    " Remove last trailing empty line
    if !empty(l:formatted_lines) && l:formatted_lines[-1] == ""
        call remove(l:formatted_lines, -1)
    endif

    " Calculate max width of the text block for centering
    let l:max_width = 0
    for l:line in l:formatted_lines
        if strlen(l:line) > l:max_width
            let l:max_width = strlen(l:line)
        endif
    endfor

    " Center titles within max_width
    for l:i in range(len(l:formatted_lines))
        let l:line = l:formatted_lines[l:i]
        if index(l:headers, l:line) >= 0
            let l:padding = (l:max_width - strlen(l:line)) / 2
            let l:formatted_lines[l:i] = repeat(" ", l:padding) . l:line
        endif
    endfor

    " Get window dimensions
    let l:win_width = winwidth(0)
    let l:win_height = winheight(0)

    " Calculate padding
    let l:h_pad_len = (l:win_width - l:max_width) / 2
    let l:v_pad_len = (l:win_height - len(l:formatted_lines)) / 2

    if l:h_pad_len < 0 | let l:h_pad_len = 0 | endif
    if l:v_pad_len < 0 | let l:v_pad_len = 0 | endif

    let l:h_pad = repeat(" ", l:h_pad_len)
    let l:v_pad = repeat([""], l:v_pad_len)

    " Prepare final lines
    let l:output = l:v_pad
    for l:line in l:formatted_lines
        call add(l:output, l:h_pad . l:line)
    endfor

    " Set buffer content
    call setline(1, l:output)

    " Apply syntax highlighting
    syntax clear
    highlight default StartScreenHeader cterm=bold gui=bold
    highlight default StartScreenShortcut cterm=italic gui=italic
    highlight default StartScreenCommand cterm=italic gui=italic

    " Match headers
    for l:header in l:headers
        execute 'syntax match StartScreenHeader /^\s*' . escape(l:header, '/.*^$[]\') . '$/'
    endfor

    " Match shortcuts and commands by calculating their positions
    let l:cur_y = l:v_pad_len + 1
    for l:block in a:blocks
        let l:start_y = l:cur_y
        if has_key(l:block, 'title')
            let l:cur_y += 1
            let l:start_y = l:cur_y
        endif

        if has_key(l:block, 'items') && !empty(l:block.items)
            let l:max_k = 0
            let l:max_d = 0
            let l:has_cmd = 0
            for l:item in l:block.items
                let l:k = (type(l:item) == v:t_list) ? get(l:item, 0, "") : get(l:item, "shortcut", "")
                let l:d = (type(l:item) == v:t_list) ? get(l:item, 1, "") : get(l:item, "description", "")
                if strlen(l:k) > l:max_k | let l:max_k = strlen(l:k) | endif
                if strlen(l:d) > l:max_d | let l:max_d = strlen(l:d) | endif
                if (type(l:item) == v:t_list && len(l:item) > 2) || (type(l:item) == v:t_dict && has_key(l:item, "command"))
                    let l:has_cmd = 1
                endif
            endfor

            let l:end_y = l:start_y + len(l:block.items) - 1
            let l:line_range = '\%>' . (l:start_y - 1) . 'l\%<' . (l:end_y + 1) . 'l'
            
            if l:max_k > 0
                execute 'syntax match StartScreenShortcut /' . l:line_range . '\%' . (l:h_pad_len + 1) . 'v\S\+/'
            endif
            
            if l:has_cmd
                let l:cmd_col = l:h_pad_len + 1
                if l:max_k > 0 | let l:cmd_col += l:max_k + 2 | endif
                let l:cmd_col += l:max_d + 2
                execute 'syntax match StartScreenCommand /' . l:line_range . '\%' . l:cmd_col . 'v\S.*$/'
            endif
            
            let l:cur_y += len(l:block.items)
        endif
        let l:cur_y += 1 " separator
    endfor

    setlocal nomodifiable
    normal! gg
endfunction
