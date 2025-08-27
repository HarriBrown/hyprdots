" Binary Harbinger neovim Theme
hi clear
if exists("syntax_on")
  syntax reset
endif
set background=dark
let g:colors_name = "akaiyama"

" Temel renkler
hi Normal       guifg=#FFCACA guibg=#515659
hi Comment      guifg=#5f875f gui=italic
hi Constant     guifg=#d7875f
hi Identifier   guifg=#87afd7
hi Statement    guifg=#af5fff gui=bold
hi PreProc      guifg=#ffaf87
hi Type         guifg=#87ffaf
hi Special      guifg=#ff875f
hi Todo         guifg=#ffff00 guibg=#5f0000

" Satır numaraları ve seçim
hi LineNr       guifg=#414447
hi CursorLineNr guifg=#FFCACA gui=bold
hi CursorLine   guibg=#2a2a2a

