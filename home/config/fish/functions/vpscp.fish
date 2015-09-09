function vpscp --description 'cp files to vps'
	rsync -av -P $argv[1] 103.243.27.70:$argv[2]
end
