#!/bin/bash

has_parallel() {
    command -v parallel >/dev/null 2>&1
}

parallel_delete() {
    if has_parallel; then
        parallel --will-cite -j 50% git branch -D ::: "$@"
    else
        xargs git branch -D
    fi
}

parallel_remote_delete() {
    if has_parallel; then
        parallel --will-cite -j 50% git push origin --delete ::: "$@"
    else
        xargs -I {} git push origin --delete {}
    fi
}

purge() {
    local p=$1
    local remote=${2:-false}
    
    git fetch --prune
    local branches=$(git branch --merged main | grep -v "^\*\|main\|master\|develop" | grep -iE "$p")
    
    if [ -n "$branches" ]; then
        echo "$branches"
        read -p "[y/n]: " ok
        
        if [ "$ok" = "y" ]; then
            if has_parallel; then
                echo "$branches" | tr -d ' *' | parallel_delete
            else
                echo "$branches" | xargs git branch -D
            fi
            
            if [ "$remote" = true ]; then
                if has_parallel; then
                    echo "$branches" | tr -d ' *' | parallel_remote_delete
                else
                    echo "$branches" | sed 's/^[* ]*//' | xargs -I {} git push origin --delete {}
                fi
            fi
        fi
    fi
}

old() {
    local d=$1
    local p=${2:-".*"}
    
    git for-each-ref --sort=committerdate refs/heads/ --format='%(refname:short)|%(committerdate:relative)' | 
    grep -iE "$p" |
    while IFS='|' read branch date; do
        if [[ $date =~ ([0-9]+)\ days\ ago && ${BASH_REMATCH[1]} -ge $d ]]; then
            echo "$branch ($date)"
        fi
    done
}

pick() {
    local branches=$(git branch | grep -v "^\*\|main\|master\|develop")
    
    if [ -z "$branches" ]; then
        return
    fi
    
    echo "Pick numbers to remove:"
    local i=1
    local arr=()
    
    while read -r branch; do
        arr+=("$branch")
        local last=$(git log -1 --format="%cr" "$branch")
        echo "[$i] $branch ($last)"
        ((i++))
    done <<< "$branches"
    
    read -p "[0-9 a/q]: " nums
    
    case $nums in
        q) return ;;
        a) 
            if has_parallel; then
                printf "%s\n" "${arr[@]}" | parallel_delete
            else
                for branch in "${arr[@]}"; do
                    git branch -D "$branch"
                done
            fi
            ;;
        *)
            local selected=()
            for num in $nums; do
                if [ "$num" -le "${#arr[@]}" ]; then
                    selected+=("${arr[$((num-1))]}")
                fi
            done
            if has_parallel; then
                printf "%s\n" "${selected[@]}" | parallel_delete
            else
                for branch in "${selected[@]}"; do
                    git branch -D "$branch"
                done
            fi
            ;;
    esac
}
