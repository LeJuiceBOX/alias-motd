#!/usr/bin/env bash
#
# alias-motd.sh - show a table of your aliases from ~/.bash_aliases
#
# A comment line starting with "##" directly above an alias is used as that
# alias's description. Aliases without one get a blank description.
#
#   ## List everything, long format
#   alias ll='ls -alF'
#
# Usage: alias-motd.sh [aliases-file]    (defaults to ~/.bash_aliases)

alias_file="${1:-$HOME/.bash_aliases}"
[[ -r $alias_file ]] || exit 0

re_alias='^[[:space:]]*alias[[:space:]]+([^=[:space:]]+)='
re_desc='^[[:space:]]*##+[[:space:]]*(.*)$'

keys=()
descs=()
prev=""

# --- Parse the aliases file -------------------------------------------------
while IFS= read -r line || [[ -n $line ]]; do
    line=${line%$'\r'}                              # tolerate CRLF endings
    if [[ $line =~ $re_alias ]]; then
        key=${BASH_REMATCH[1]}
        desc=""
        if [[ $prev =~ $re_desc ]]; then
            desc=${BASH_REMATCH[1]}
            desc=${desc%"${desc##*[![:space:]]}"}   # trim trailing spaces
        fi
        keys+=("$key")
        descs+=("$desc")
    fi
    prev=$line
done < "$alias_file"

(( ${#keys[@]} )) || exit 0

# --- Column widths ----------------------------------------------------------
head_k="Alias"
head_d="Description"
kw=${#head_k}
dw=${#head_d}
for i in "${!keys[@]}"; do
    (( ${#keys[i]}  > kw )) && kw=${#keys[i]}
    (( ${#descs[i]} > dw )) && dw=${#descs[i]}
done

# Keep the table inside the terminal; long descriptions get truncated with "…"
cols=$(tput cols 2>/dev/null)
cols=${cols:-80}
max_dw=$(( cols - kw - 7 ))
(( max_dw < 10 )) && max_dw=10
(( dw > max_dw )) && dw=$max_dw

# --- Styling (only when writing to a terminal) -------------------------------
if [[ -t 1 ]]; then
    bold=$'\e[1m' cyan=$'\e[36m' dim=$'\e[2m' reset=$'\e[0m'
else
    bold="" cyan="" dim="" reset=""
fi
v="${dim}│${reset}"

# --- Drawing helpers (no subshells, so it stays fast on every new terminal) --
hr() {  # hr LEFT MID RIGHT
    local a b
    printf -v a '%*s' $(( kw + 2 )) ''; a=${a// /─}
    printf -v b '%*s' $(( dw + 2 )) ''; b=${b// /─}
    printf '%s%s%s%s%s%s\n' "$dim" "$1" "$a" "$2" "$b" "$3$reset"
}

pad() {  # pad TEXT WIDTH  -> REPLY holds TEXT truncated/padded to WIDTH
    local t=$1 w=$2
    (( ${#t} > w )) && t="${t:0:w-1}…"
    printf -v REPLY '%s%*s' "$t" $(( w - ${#t} )) ''
}

row() {  # row KEY DESC KEY_STYLE DESC_STYLE
    local k d
    pad "$1" "$kw"; k=$REPLY
    pad "$2" "$dw"; d=$REPLY
    printf '%s %s%s%s %s %s%s%s %s\n' "$v" "$3" "$k" "$reset" "$v" "$4" "$d" "$reset" "$v"
}

# --- Output -----------------------------------------------------------------
hr ┌ ┬ ┐
row "$head_k" "$head_d" "$bold" "$bold"
hr ├ ┼ ┤
for i in "${!keys[@]}"; do
    row "${keys[i]}" "${descs[i]}" "$cyan" ""
done
hr └ ┴ ┘
