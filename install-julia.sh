# Check that we are running inside Google Colab
if [ -n "$COLAB_GPU" ]; then
  FULL_VERSION="$(sed -r 's|.*([0-9]+\.[0-9]+\..*)|\1|' <<< $1)"
  MAJOR_MINOR_VERSION="$(sed -r 's|.*([0-9]+\.[0-9]+)\..*|\1|' <<< $1)"
  BASE_URI="https://julialang-s3.julialang.org/bin/linux/x64"

  # Check if Julia is not installed, or if the installed version is not the required version
  if ! command -v julia 3>&1 > /dev/null || [ "$(sed -r 's|.*([0-9]+\.[0-9]+\..*)|\1|' <<< $(julia --version))" != "$FULL_VERSION" ]
  then
      URI="$BASE_URI/$MAJOR_MINOR_VERSION/julia-$FULL_VERSION-linux-x86_64.tar.gz"
      wget -q $URI -O /tmp/julia.tar.gz
      tar -x -f /tmp/julia.tar.gz -C /usr/local --strip-components 1
      rm /tmp/julia.tar.gz
  fi

  # Installing packages
  for PACKAGE in IJulia "${@:2}"; do
    if [ "$PACKAGE" != "CUDA" ] || [ "$COLAB_GPU" = "1" ]; then
      julia -e '
      using Pkg;
      pkg"add '$PACKAGE'; precompile;"
      '
    fi
  done

  # Defining number of threds to be used by Julia
  CPU_CORE_THREADS=$(
    cat /proc/cpuinfo | \
    grep 'cpu cores' | \
    sed -r 's/cpu cores[[:space:]]*:[[:space:]]*(.*)/\1/'
    )
  THREADS=$(( ${CPU_CORE_THREADS//$'\n'/+} ))
  julia -e '
  using IJulia;
  IJulia.installkernel(
    "julia",
    env=Dict("JULIA_NUM_THREADS"=>"'$THREADS'"))
  '

  # Renaming Julia path to match the kernel name inside `julia.ipynb`
  KERNEL_DIR=`julia -e '
    using IJulia;
    print(IJulia.kerneldir())
    '`
  KERNEL_NAME=`ls -d "$KERNEL_DIR"/julia*`
  mv -f $KERNEL_NAME "$KERNEL_DIR"/julia
fi
