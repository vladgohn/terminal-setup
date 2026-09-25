# Sourced from ~/.bashrc by a block written by install.sh.

[[ $- != *i* ]] && return

TERMINAL_SETUP_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export PATH="$HOME/.local/bin:$PATH"

write_gradient() {
    local from=(255 0 200) to=(0 220 255)
    local line len i t r g b
    while IFS= read -r line; do
        len=${#line}
        (( len < 2 )) && len=2
        for (( i = 0; i < ${#line}; i++ )); do
            r=$(( from[0] + (to[0] - from[0]) * i / (len - 1) ))
            g=$(( from[1] + (to[1] - from[1]) * i / (len - 1) ))
            b=$(( from[2] + (to[2] - from[2]) * i / (len - 1) ))
            printf '\e[38;2;%d;%d;%dm%s' "$r" "$g" "$b" "${line:i:1}"
        done
        printf '\e[0m\n'
    done
}

if command -v figlet >/dev/null; then
    figlet -f slant "$(hostname | tr '[:lower:]' '[:upper:]')" | write_gradient
fi

if command -v oh-my-posh >/dev/null; then
    eval "$(oh-my-posh init bash --config "$TERMINAL_SETUP_ROOT/theme/skat.omp.json")"
fi
