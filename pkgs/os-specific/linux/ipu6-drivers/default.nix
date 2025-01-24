{
  lib,
  stdenv,
  fetchFromGitHub,
  ivsc-driver,
  kernel,
}:

stdenv.mkDerivation rec {
  pname = "ipu6-drivers";
  version = "unstable-2025-01-19";

  src = fetchFromGitHub {
    owner = "jwrdegoede";
    repo = "ipu6-drivers";
    rev = "f2a1b54afd8537f52f17adcadd7d3e064cf704a3";
    hash = "sha256-28+ho4QN09dZ3N0DFoYnntgTLHqEWK2+MTAz8nzC8IY=";
  };

  patches = [
    "${src}/patches/0001-v6.10-IPU6-headers-used-by-PSYS.patch"
  ];

  postPatch = ''
    cp --no-preserve=mode --recursive --verbose \
      ${ivsc-driver.src}/backport-include \
      ${ivsc-driver.src}/drivers \
      ${ivsc-driver.src}/include \
      .
  '';

  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = kernel.makeFlags ++ [
    "KERNELRELEASE=${kernel.modDirVersion}"
    "KERNEL_SRC=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  enableParallelBuilding = true;

  preInstall = ''
    sed -i -e "s,INSTALL_MOD_DIR=,INSTALL_MOD_PATH=$out INSTALL_MOD_DIR=," Makefile
  '';

  installTargets = [
    "modules_install"
  ];

  meta = {
    homepage = "https://github.com/intel/ipu6-drivers";
    description = "IPU6 kernel driver";
    license = lib.licenses.gpl2Only;
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
    # requires 6.10
    broken = kernel.kernelOlder "6.10";
  };
}
