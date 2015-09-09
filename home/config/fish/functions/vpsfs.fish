function vpsfs --description 'mount vpsfs and cd to it'
	if not mount | grep vpsfs
mkdir -p /tmp/workspace/vpsfs
sshfs vpsfs:/home/aetf /tmp/workspace/vpsfs
end
cd /tmp/workspace/vpsfs
end
