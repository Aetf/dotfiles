
CopyFile /etc/subgid
CopyFile /etc/subuid
AddPackage podman # Tool and library for running OCI-based containers in pods
AddPackage podman-compose # A script to run docker-compose.yml using podman
AddPackage buildah # A tool which facilitates building OCI images

# For build and run container image in foreign architecture
AddPackage qemu-user-static
AddPackage qemu-user-static-binfmt
