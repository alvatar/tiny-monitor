" Quick settings
let g:projectPath = "/data/projects/monitor"
let g:programName = "Monitor"
let makeString = "./build.sh"

" Paths and global variables for custom functions
execute "cd ".g:projectPath."/__deploy"
" Load Session before loading custom configuration
source Session.vim
let CTags_CScope_Top_Dir = g:projectPath."/__deploy"
let CTags_CScope_Dir_List = g:projectPath.".."
let Make_Dir = g:projectPath."/__deploy"
execute "set path+=".g:projectPath."**"

" Make command (used previously for make string formatting)
" let formatedMakeString = substitute(makeString, " ", "\\\\ ", "g")
" execute "set makeprg=".formatedMakeString
execute "set makeprg=".makeString

" View imports graph
function! ViewImportsGraph()
	execute "cd ".g:projectPath."/__deploy"
	execute "!./graph.sh"
endfunction

" Run program
function! RunProgram()
	execute "cd ".g:projectPath."/__deploy"
	execute "!./run.sh"
endfunction

" Clean Xfbuilds' excrements
function! CleanProgram()
	execute "cd ".g:projectPath."/__deploy"
	execute "!./clean.sh"
endfunction

" Shortcuts
nnoremap <F3> :vimgrep /<C-R><C-W>/ **<CR>
noremap <F8> :call ViewImportsGraph()<CR>
noremap <F9> :call RunProgram()<CR>
noremap <F10> :call CleanProgram()<CR>
noremap <F11> :call Compile(1)<CR>
inoremap <F11> <ESC>:call Compile(1)<CR>
nnoremap <F12> :call BuildCTagsAndCSCopeDatabase("d")<CR>
