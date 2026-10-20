#!/usr/bin/env bash

set -euo pipefail

mode="check"
root_dir="$(pwd)"

usage() {
    printf 'Usage: %s [--check|--write]\n' "${0##*/}"
}

case "${1:---check}" in
    --check) ;;
    --write) mode="write" ;;
    --help|-h) usage; exit 0 ;;
    *) usage >&2; exit 2 ;;
esac

is_sha() {
    [[ "$1" =~ ^[0-9a-f]{40}$ ]]
}

git_url() {
    printf 'https://github.com/%s.git' "$1"
}

resolve_ref() {
    local repository="$1"
    local reference="$2"
    local remote_url

    remote_url="$(git_url "$repository")"
    if [[ "$reference" == "HEAD" ]]; then
        git ls-remote "$remote_url" HEAD | awk 'NR == 1 { print $1 }'
        return
    fi
    git ls-remote "$remote_url" "refs/tags/$reference" "refs/heads/$reference" \
        | awk 'NR == 1 { print $1 }'
}

release_tag() {
    local repository="$1"
    local revision="$2"
    local remote_url

    remote_url="$(git_url "$repository")"
    git ls-remote --tags "$remote_url" | awk -v revision="$revision" '
        $1 == revision {
            sub("refs/tags/", "", $2)
            sub("\\^\\{\\}$", "", $2)
            print $2
            exit
        }'
}

rewrite_workflow() {
    local workflow="$1"
    local temp_file line prefix repository reference suffix revision tag findings=0

    temp_file="$(mktemp)"
    while IFS= read -r line || [[ -n "$line" ]]; do
        if [[ "$line" =~ ^([[:space:]]*-?[[:space:]]*uses:[[:space:]]*)([^@[:space:]#]+)@([^[:space:]#]+)([[:space:]]*(#.*)?)$ ]]; then
            prefix="${BASH_REMATCH[1]}"
            repository="${BASH_REMATCH[2]}"
            reference="${BASH_REMATCH[3]}"
            suffix="${BASH_REMATCH[4]}"

            if ! is_sha "$reference"; then
                revision="$(resolve_ref "$repository" "$reference")"
                if [[ -z "$revision" ]]; then
                    printf 'Unable to resolve %s@%s\n' "$repository" "$reference" >&2
                    rm -f "$temp_file"
                    return 1
                fi

                if [[ "$mode" == "write" ]]; then
                    printf '%s%s@%s # %s\n' "$prefix" "$repository" "$revision" "$reference" >> "$temp_file"
                else
                    printf 'Mutable action reference: %s@%s\n' "$repository" "$reference" >&2
                    findings=1
                fi
                continue
            fi
        fi
        printf '%s\n' "$line" >> "$temp_file"
    done < "$workflow"

    if [[ "$mode" == "write" ]]; then
        mv "$temp_file" "$workflow"
    else
        rm -f "$temp_file"
    fi

    return "$findings"
}

rewrite_requirements() {
    local requirements="$1"
    local temp_file line prefix organization project reference revision tag findings=0

    temp_file="$(mktemp)"
    while IFS= read -r line || [[ -n "$line" ]]; do
        if [[ "$line" =~ ^(.*git\+https://github\.com/([^/]+)/([^/@[:space:]#]+)\.git)(@([^[:space:]#]+))?([[:space:]]*(#.*)?)$ ]]; then
            prefix="${BASH_REMATCH[1]}"
            organization="${BASH_REMATCH[2]}"
            project="${BASH_REMATCH[3]}"
            reference="${BASH_REMATCH[5]:-HEAD}"

            if ! is_sha "$reference"; then
                revision="$(resolve_ref "$organization/$project" "$reference")"
                if [[ -z "$revision" ]]; then
                    printf 'Unable to resolve %s@%s\n' "$organization/$project" "$reference" >&2
                    rm -f "$temp_file"
                    return 1
                fi
                tag="$(release_tag "$organization/$project" "$revision")"

                if [[ "$mode" == "write" ]]; then
                    if [[ -n "$tag" ]]; then
                        printf '%s@%s # %s\n' "$prefix" "$revision" "$tag" >> "$temp_file"
                    else
                        printf '%s@%s # No matching upstream release tag\n' "$prefix" "$revision" >> "$temp_file"
                    fi
                else
                    printf 'Mutable dependency reference: %s@%s\n' "$organization/$project" "$reference" >&2
                    findings=1
                fi
                continue
            fi
        fi
        printf '%s\n' "$line" >> "$temp_file"
    done < "$requirements"

    if [[ "$mode" == "write" ]]; then
        mv "$temp_file" "$requirements"
    else
        rm -f "$temp_file"
    fi

    return "$findings"
}

status=0
while IFS= read -r workflow; do
    rewrite_workflow "$workflow" || status=1
done < <(find "$root_dir/.github/workflows" -type f \( -name '*.yml' -o -name '*.yaml' \) | sort)

rewrite_requirements "$root_dir/requirements.in" || status=1

if [[ "$mode" == "check" ]] && [[ "$status" -eq 0 ]]; then
    printf 'All Git dependencies and workflow actions are pinned.\n'
fi

exit "$status"