" .vimrc
"
" :call Tabs()     Sets tabs to tabs
" :call Spaces()   Sets tabs to spaces
"
function! Tabs()
  " Using 4 column tabs
  set softtabstop=4
  set shiftwidth=4
  set tabstop=4
  set noexpandtab
  autocmd User Rails set softtabstop=4
  autocmd User Rails set shiftwidth=4
  autocmd User Rails set tabstop=4
  autocmd User Rails set noexpandtab
endfunction
 
function! Spaces()
  " Use 4 spaces
  set softtabstop=4
  set shiftwidth=4
  set tabstop=4
  set expandtab
endfunction
 
call Spaces()

set autoindent
set smartindent
set cindent

if &t_Co > 1
  syntax on
  set background=dark
  colorscheme blackboard
endif

" set syntax highlighting for non-standard files
au BufRead,BufNewFile *.pde     setfiletype cpp
