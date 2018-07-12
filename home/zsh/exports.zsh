# Set default programs
export EDITOR=vim
export CC=gcc
export CXX=g++

# Java
export JAVA_HOME=/usr/lib/jvm/java-8-oracle

# Cuda
if [[ -d /usr/local/cuda ]]; then
    export CUDA_HOME=/usr/local/cuda
    export CUDA_ROOT=$CUDA_HOME
    autodetect_path $CUDA_HOME
fi

# Go language
export GOROOT=$TOOL_DIR/go
export GOPATH=$TOOL_DIR/gopath
export GOBIN=$TOOL_DIR/gopath/bin

# Spack package manager
export SPACK_ROOT=$HOME/.local/spack
PATH=$PATH:$SPACK_ROOT/bin
# don't load shell integration, which is too slow. We explicitly set MODULEPATH
# common used modules are loaded as spack view in $TOOL_DIR/spack_packages
#. $SPACK_ROOT/share/spack/setup-env.sh
#export MODULEPATH=$TOOL_DIR/spack/share/spack/lmod/linux-rhel7-ppc64le/Core:/gpfs/gpfs0/software/rhel72/conflux-modules/modulefiles
