function cpwd --description 'Copy pwd to X clipboard'
	pwd | tr -d '\n' | xsel --clipboard --input
end
