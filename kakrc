def -params 1 -docstring "colorscheme <name>: enable named colorscheme" \
    -shell-script-candidates %{
    find -L "${kak_runtime}/colors" "${kak_config}/colors" -type f -name '*\.kak' \
        | while read -r filename; do
            basename="${filename##*/}"
            printf %s\\n "${basename%.*}"
        done | sort -u
  } \
  colorscheme %{ evaluate-commands %sh{
    find_colorscheme() {
        find -L "${1}" -type f -name "${2}".kak | head -n 1
    }

    filename=""
    if [ -d "${kak_config}/colors" ]; then
        filename=$(find_colorscheme "${kak_config}/colors" "${1}")
    fi
    if [ -z "${filename}" ]; then
        filename=$(find_colorscheme "${kak_runtime}/colors" "${1}")
    fi

    if [ -n "${filename}" ]; then
        printf 'source %%{%s}' "${filename}"
    else
        echo "fail 'No such colorscheme ${1}.kak'"
    fi
}}

evaluate-commands %sh{
    autoload_directory() {
        find -L "$1" -type f -name '*\.kak' \
            | sed 's/.*/try %{ source "&" } catch %{ echo -debug Autoload: could not load "&" }/'
    }

    echo "colorscheme default"

    if [ -d "${kak_config}/autoload" ]; then
        autoload_directory ${kak_config}/autoload
    elif [ -d "${kak_runtime}/autoload" ]; then
        autoload_directory ${kak_runtime}/autoload
    fi

    if [ -f "${kak_runtime}/kakrc.local" ]; then
        echo "source '${kak_runtime}/kakrc.local'"
    fi

    if [ -f "${kak_config}/kakrc" ]; then
        echo "source '${kak_config}/kakrc'"
    fi
}

################
###  CUSTOM  ###
################

add-highlighter global/ show-matching
add-highlighter global/ wrap -indent
set-option global autocomplete insert
set-option global tabstop 2
set-option global indentwidth 2


# Display line numbers everywhere, but using buffer makes them removable.
hook -always global BufCreate .* %§
  add-highlighter buffer/my-line-numbers number-lines -relative -separator ' ' -min-digits '2'
§


# Colors
# ‾‾‾‾‾‾
# WarpMaker is not visible, instead it seems to be LineNumbersWrapped
#set-face global WrapMarker         rgb:948975,rgb:1b1a1a+Ffga@rgb:1b1a1a
set-face global LineNumbersWrapped rgb:948975,rgb:1b1a1a+Ffga@rgb:1b1a1a


# Clipboard
# ‾‾‾‾‾‾‾‾‾
hook global RegisterModified '"' %{ nop %sh{
  if [ -n "$DISPLAY" ]; then
    printf %s "$kak_main_reg_dquote" | xsel --input --clipboard
  elif [ -n "$TMUX" ]; then
    tmux set-buffer -- "$kak_main_reg_dquote"
  fi
}}

# Paste after
map global user p -docstring "Paste after" '<a-!>xsel --output --clipboard<ret>'
# Paste before
map global user P -docstring "Paste before" '!xsel --output --clipboard<ret>'
# Replace selection
map global user R -docstring "Replace selection" '|xsel --output --clipboard<ret>'

# Exec Shell Command


# Key-Mappings
# ‾‾‾‾‾‾‾‾‾‾‾‾
map global normal '#' ':comment-line<ret>'
map global normal '$' ':comment-block<ret>'
unmap global i <c-s> #Don't want to close kakoune without saving
map global insert <c-s> '<a-semicolon>:write<ret>'

# key mappings, options and hooks for V language files
hook global WinSetOption filetype=v %§
  require-module v
  map -docstring "Format and save current file"	window normal <F5> ":v-fmt<ret>"
  map -docstring 'Run v in v.mod directory'	window normal <F6> ":v-run<ret>"
  map -docstring 'Switch to debug buffer'	window normal <F7> ":buffer *debug*<ret>"
  map -docstring 'Switch to previous buffer'	global normal <F8> ":buffer-previous;delete-buffer *debug*<ret>"
  set-option buffer v_output_to_info_box	true
  set-option buffer v_output_to_debug_buffer	true

  # Add semantic tokens highlighting
  hook window -group semantic-tokens BufReload .* lsp-semantic-tokens
  hook window -group semantic-tokens NormalIdle .* lsp-semantic-tokens
  hook window -group semantic-tokens InsertIdle .* lsp-semantic-tokens
  hook -once -always window WinSetOption filetype=.* %{
    remove-hooks window semantic-tokens
  }
§

# Search user mode
declare-user-mode search
map -docstring "Search mode" global user / %{:enter-user-mode search<ret>} 
map -docstring 'case insensitive search' global search / /(?i)
map -docstring 'case insensitive backward search' global search <a-/> <a-/>(?i)
map -docstring 'case insensitive extend search' global search ? ?(?i)
map -docstring 'case insensitive backward extend-search' global search <a-?> <a-?>(?i)

# kaktree file browser https://git.sr.ht/~teddy/kaktree
#source "/home/anton/workspace/kakoune/rc/kaktree/rc/kaktree.kak"
# Remove hightlighters from kaktree
hook global WinSetOption filetype=kaktree %{
    remove-highlighter buffer/my-line-numbers
    remove-highlighter buffer/show-matching
    remove-highlighter buffer/numbers
    remove-highlighter buffer/matching
    remove-highlighter buffer/wrap
    remove-highlighter buffer/show-whitespaces
    set-option global kaktree_double_click_duration '0.5'
    set-option global kaktree_indentation 1
    set-option global kaktree_dir_icon_open  '▾ 🗁 '
    set-option global kaktree_dir_icon_close '▸ 🗀 '
    set-option global kaktree_file_icon      '⠀⠀🖺'
    set-option global kaktree_size           '25'
    set-option global kaktree_sort           1
}
kaktree-enable

# Suggested by kak-lsp https://github.com/kak-lsp/kak-lsp/blob/master/README.asciidoc#configure-mappings
map global user l %{:enter-user-mode lsp<ret>} -docstring "LSP mode"
map global insert <tab> '<a-;>:try lsp-snippets-select-next-placeholders catch %{ execute-keys -with-hooks <lt>tab> }<ret>' -docstring 'Select next snippet placeholder'
map global object a '<a-semicolon>lsp-object<ret>' -docstring 'LSP any symbol'
map global object <a-a> '<a-semicolon>lsp-object<ret>' -docstring 'LSP any symbol'
map global object e '<a-semicolon>lsp-object Function Method<ret>' -docstring 'LSP function or method'
map global object k '<a-semicolon>lsp-object Class Interface Struct<ret>' -docstring 'LSP class interface or struct'
map global object d '<a-semicolon>lsp-diagnostic-object --include-warnings<ret>' -docstring 'LSP errors and warnings'
map global object D '<a-semicolon>lsp-diagnostic-object<ret>' -docstring 'LSP errors'

declare-user-mode grep
define-command grep-selection %{
  execute-keys ":grep <space> <c-r>. <ret>"
}
map global user g ':enter-user-mode grep<ret>' -docstring 'Grep mode'
map global grep g ':grep ' -docstring 'run grep'
map global grep p ':grep-previous-match<ret>' -docstring 'run grep-previous-match'
map global grep n ':grep-next-match<ret>' -docstring 'run grep-next-match'
map global grep l ':edit -existing *grep* <ret>' -docstring 'show grep results'
map global grep s ':grep-selection <ret>' -docstring 'grep selection'

hook global BufSetOption filetype=html %{
  set-option buffer comment_block_begin "<!--"
  set-option buffer comment_block_end "-->"
}



# Building and Running AntonsDungeonKeeper
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
define-command run-adk -docstring 'Run AntonsDungeonKeeper executable' %{
# Open new tmux window and run
	nop %sh{ tmux new-window './bin/antonsdungeonkeeper' }
}

hook global -always BufOpenFifo '\*make\*' %{ map global normal <F2> ': make-next-error<ret>' }
map -docstring "Close current buffer" global normal <F4> ":db<ret>"
hook global WinSetOption filetype=(c|cpp) %§
set-option global makecmd '~/workspace/meson/meson.py compile -j4 -C build && ~/workspace/meson/meson.py install -C build'
  map -docstring "Save file and make"		window normal <F1> ": wa<semicolon>make<ret>"
  map -docstring "Go to previous buffer"	global normal <F3> ": bp<ret>"
  map -docstring "Run antonsdungeonkeeper"	global normal <F5> ":run-adk<ret>"
§


# Kak-Language Server Protocol Client
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
eval %sh{ . ~/workspace/set_environment_stuff_to_newest_gcc_and_ccls.sh && kak-lsp --kakoune --config $HOME/workspace/kak-lsp/config.toml -s $kak_session }
#DEBUG log to /tmp/kak-lsp.log
# source gcc-master environment vars. sh uses . instead of source for this
# nop %sh{ (. ~/workspace/set_environment_stuff_to_newest_gcc_and_ccls.sh && kak-lsp --kakoune --config $HOME/workspace/kak-lsp/config.toml -s $kak_session -vvv ) > /tmp/kak-lsp.log 2>&1 < /dev/null & }

# Close kak-lsp when kakoune is closed
hook global KakEnd .* lsp-exit
# When VLS throws errors after a Kakoune restart is
# when you absolutely, positively, have to kill a process
#hook global KakEnd .* %sh{ kill $(ps ax | grep "kak-lsp" | awk '{print $1}') }

# Enable kak-lsp for different files
hook global WinSetOption filetype=(v|c|cpp|cmake) %{
    lsp-enable-window
}


# TMP Hook Testing
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
# declare-option bool currently_working_on_project false
# hook global BufCreate .* %[
#   set-option global currently_working_on_project %sh{
#     find . -name "my_project_file" | read -r na && echo yes || ! echo no
#   }
# ]

# hook global WinSetOption currently_working_on_project=true %{
#   colorscheme base16
# }
