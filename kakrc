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


add-highlighter global/ number-lines -separator ' ' -relative
add-highlighter global/ show-matching
add-highlighter global/ wrap -indent
set-option global autocomplete insert
set-option global tabstop 2
set-option global indentwidth 2


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

#Paste before
map global user P -docstring "Paste before" '!xsel --output --clipboard<ret>'
#Paste after
map global user p -docstring "Paste after" '<a-!>xsel --output --clipboard<ret>'
#Replace selection
map global user R -docstring "Replace selection" '|xsel --output --clipboard<ret>'


# Key-Mappings
# ‾‾‾‾‾‾‾‾‾‾‾‾
map global normal '#' :comment-line<ret>
map global normal '$' :comment-block<ret>

# key mappings for V language files
hook global WinSetOption filetype=v %§
  require-module v
  map -docstring "Format and save current file"	window normal <F5> ":v-fmt<ret>"
  map -docstring 'Run v in v.mod directory'	window normal <F6> ":v-run<ret>"
  map -docstring 'Switch to debug buffer'	window normal <F7> ":buffer *debug*<ret>"
  map -docstring 'Switch to previous buffer'	global normal <F8> ":buffer-previous;delete-buffer *debug*<ret>"
  set-option buffer v_output_to_info_box	true
  set-option buffer v_output_to_debug_buffer	true
§
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
map global user g ':enter-user-mode grep<ret>' -docstring 'enter grep mode'
map global grep g ':grep ' -docstring 'run grep'
map global grep p ':grep-previous-match<ret>' -docstring 'run grep-previous-match'
map global grep n ':grep-next-match<ret>' -docstring 'run grep-next-match'
map global grep l ':edit -existing *grep* <ret>' -docstring 'show grep results'
map global grep s ':grep-selection <ret>' -docstring 'grep selection'


# Building and Running AntonsDungeonKeeper
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
define-command run-adk -docstring 'Run AntonsDungeonKeeper executable' %{
# Open new tmux window and run
	nop %sh{ tmux new-window './bin/antonsdungeonkeeper' }
}

hook global -always BufOpenFifo '\*make\*' %{ map global normal <F2> ': make-next-error<ret>' }
hook global WinSetOption filetype=(c|cpp) %§
set-option global makecmd '~/workspace/meson/meson.py compile -j4 -C build && ~/workspace/meson/meson.py install -C build'
  map -docstring "Save file and make"		window normal <F1> ": wa<semicolon>make<ret>"
  map -docstring "Go to previous buffer"	global normal <F3> ": bp<ret>"
  map -docstring "Run antonsdungeonkeeper"	global normal <F5> ":run-adk<ret>"
§


# Kak-Language Server Protocol Client
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
eval %sh{ kak-lsp --kakoune --config $HOME/workspace/kak-lsp/config.toml -s $kak_session }
# Close kak-lsp when kakoune is closed
hook global KakEnd .* lsp-exit
# When VLS throws errors after a Kakoune restart is
# when you absolutely, positively, have to kill a process
#hook global KakEnd .* %sh{ kill $(ps ax | grep "kak-lsp" | awk '{print $1}') }

# Enable kak-lsp for different files
hook global WinSetOption filetype=(c|cpp|cmake) %{
    lsp-enable-window
}

#DEBUG
nop %sh{ (kak-lsp --config $HOME/workspace/kak-lsp/config.toml -s $kak_session -vvv ) > /tmp/kak-lsp.log 2>&1 < /dev/null & }

