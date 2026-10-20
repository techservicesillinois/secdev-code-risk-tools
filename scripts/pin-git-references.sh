#!/usr/bin/env bash
set -euo pipefail

mode=check
root_dir="$(pwd)"
case "${1:---check}" in
    --check) ;;
    --write) mode=write ;;
    --help|-h) echo "Usage: ${0##*/} [--check|--write]"; exit 0 ;;
    *) echo "Usage: ${0##*/} [--check|--write]" >&2; exit 2 ;;
esac

resolve_ref() { local url="https://github.com/$1.git"; if [[ "$2" == HEAD ]]; then git ls-remote "$url" HEAD; else git ls-remote "$url" "refs/tags/$2" "refs/heads/$2"; fi | awk 'NR==1{print $1}'; }
release_tag() { git ls-remote --tags "https://github.com/$1.git" | awk -v s="$2" '$1==s{sub("refs/tags/","",$2);sub(/\^\{\}$/,"",$2);print $2;exit}'; }

# args: file regex ref-group kind("action"|"dependency")
process() {
    local file="$1" re="$2" g="$3" kind="$4" out line findings=0
    out=$(mktemp)
    while IFS= read -r line || [[ -n "$line" ]]; do
        if [[ "$line" =~ $re ]]; then
            local prefix="${BASH_REMATCH[1]}" repo="${BASH_REMATCH[2]}" ref="${BASH_REMATCH[$g]:-HEAD}"
            if [[ ! "$ref" =~ ^[0-9a-f]{40}$ ]]; then
                local sha; sha=$(resolve_ref "$repo" "$ref")
                if [[ -z "$sha" ]]; then
                    echo "Unable to resolve $repo@$ref" >&2; rm -f "$out"; return 1
                elif [[ "$mode" == write ]]; then
                    if [[ "$kind" == action ]]; then
                        printf '%s%s@%s # %s\n' "$prefix" "$repo" "$sha" "$ref" >>"$out"
                    else
                        local tag; tag=$(release_tag "$repo" "$sha")
                        printf '%s@%s # %s\n' "$prefix" "$sha" "${tag:-No matching upstream release tag}" >>"$out"
                    fi
                else
                    echo "Mutable $kind reference: $repo@$ref" >&2; findings=1
                fi
                continue
            fi
        fi
        printf '%s\n' "$line" >>"$out"
    done <"$file"
    [[ "$mode" == write ]] && mv "$out" "$file" || rm -f "$out"
    return "$findings"
}

status=0
while IFS= read -r wf; do
    process "$wf" '^([[:space:]]*-?[[:space:]]*uses:[[:space:]]*)([^@[:space:]#]+)@([^[:space:]#]+)([[:space:]]*(#.*)?)$' 3 action || status=1
done < <(find "$root_dir/.github/workflows" -type f \( -name '*.yml' -o -name '*.yaml' \) | sort)

[[ "$mode" == check && "$status" -eq 0 ]] && echo "All Git dependencies and workflow actions are pinned."
exit "$status"