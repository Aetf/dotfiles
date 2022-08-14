function MatchHost() {
    # first find caller
    local caller=$(CallerName)
    caller=$(basename "$caller" .sh)
    caller=${caller#*-}

    [[ "$(Host)" == $caller ]]
}

