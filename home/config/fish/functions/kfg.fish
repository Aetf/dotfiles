function kfg --description 'Kill background task group and do a fg'
    if jobs >/dev/null
        kill -- -(echo %1)
        fg
    end
end
