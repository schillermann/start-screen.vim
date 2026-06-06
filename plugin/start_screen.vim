vim9script

if exists('g:loaded_start_screen') | finish | endif
g:loaded_start_screen = 1

command! StartScreen call start_screen#show(get(g:, 'start_screen_blocks', []))

autocmd VimEnter * if argc() == 0 | call start_screen#show(get(g:, 'start_screen_blocks', [])) | endif
