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
set-option global tabstop 4
set-option global indentwidth 4

# Colors ! Don't seem to override alacritty colors
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
#set-face global WrapMarker rgb:656d4d

# Key-Mappings
# ‾‾‾‾‾‾‾‾‾‾‾‾
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


# Kak-Language Server Protocol Client
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
eval %sh{ kak-lsp --kakoune --config $HOME/workspace/kak-lsp/config.toml -s $kak_session }
# Close kak-lsp when kakoune is closed
hook global KakEnd .* lsp-exit
# When VLS throws errors after a Kakoune restart is
# when you absolutely, positively, have to kill a process
#hook global KakEnd .* %sh{ kill $(ps ax | grep "kak-lsp" | awk '{print $1}') }

# Enable kak-lsp for different files
hook global WinSetOption filetype=(c|cpp) %{
    lsp-enable-window
}

#DEBUGGING
#nop %sh{ (kak-lsp --config $HOME/workspace/kak-lsp/config.toml -s $kak_session -vvv ) > /tmp/kak-lsp.log 2>&1 < /dev/null & }
