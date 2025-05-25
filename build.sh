#!/usr/bin/env bash

# Build a custom WSL2 kernel with zwap

set -e
set -o pipefail

sudo apt update
sudo apt install build-essential flex bison libssl-dev libelf-dev libncurses-dev autoconf libudev-dev libtool dwarves make cmake ccache

WSL2_KERNEL_VERSION="$(uname -r | grep -o '^[0-9\.]\+')"

wget -c https://github.com/microsoft/WSL2-Linux-Kernel/archive/refs/tags/linux-msft-wsl-${WSL2_KERNEL_VERSION}.tar.gz
tar -xvf linux-msft-wsl-${WSL2_KERNEL_VERSION}.tar.gz

cd "WSL2-Linux-Kernel-linux-msft-wsl-${WSL2_KERNEL_VERSION}"

cp Microsoft/config-wsl .config           # Use WSL default kernel config as the base
cat << EOF >> .config

CONFIG_KSM=y
CONFIG_TRANSPARENT_HUGEPAGE=y
CONFIG_ZSWAP=y
CONFIG_Z3FOLD=y
CONFIG_SCHED_BORE=y
CONFIG_FRONTSWAP=y
CONFIG_ZSWAP=y
CONFIG_ZSWAP_COMPRESSOR_DEFAULT_LZO=y
CONFIG_ZSWAP_COMPRESSOR_DEFAULT="lzo"
CONFIG_ZSWAP_ZPOOL_DEFAULT_ZBUD=y
CONFIG_ZSWAP_ZPOOL_DEFAULT="zbud"
CONFIG_ZSWAP_DEFAULT_ON=y
CONFIG_ZPOOL=y
CONFIG_ZBUD=y
CONFIG_CRYPTO_LZO=y
CONFIG_SCHED_DEBUG=y
CONFIG_SCHEDSTATS=y
CONFIG_SCHED_HRTICK=y
CONFIG_SCHED_BORE=y
CONFIG_SCHED_CORE=y
CONFIG_SCHED_MC=y
CONFIG_SCHED_SMT=y
CONFIG_SCHED_AUTOGROUP=y
CONFIG_FAIR_GROUP_SCHED=y
CONFIG_CFS_BANDWIDTH=y
CONFIG_CPU_FREQ=y
CONFIG_CPU_FREQ_GOV_PERFORMANCE=y
CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE=y
CONFIG_INTEL_PSTATE=y
CONFIG_INTEL_CPUFREQ=y
CONFIG_X86_INTEL_PSTATE=y
CONFIG_ACPI_CPPC_LIB=y
CONFIG_X86_AMD_PSTATE=y
CONFIG_X86_AMD_PSTATE_UT=y
CONFIG_X86_CPU_RESCTRL=y
CONFIG_X86_ACPI_CPUFREQ=y
CONFIG_CPU_SUP_INTEL=y
CONFIG_CPU_SUP_AMD=y
CONFIG_MITIGATION_SPECTRE_V2=y
CONFIG_MITIGATION_RETPOLINE=y
CONFIG_LRU_GEN=y
CONFIG_LRU_GEN_ENABLED=y
CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS=y
CONFIG_PAGE_TABLE_ISOLATION=y
CONFIG_ZSWAP_DEFAULT_ON=y
CONFIG_ZSWAP_COMPRESSOR_DEFAULT_LZ4=y
CONFIG_LZ4_COMPRESS=y
CONFIG_LZ4HC_COMPRESS=y
EOF
make olddefconfig

make -j $(nproc)

cat << EOF

Next, copy "arch/x86/boot/bzImage" to "/mnt/c" and 
add the following to your ".wslconfig".

[wsl2]
kernel=C:\\\\bzImage

After that, restart your WSL2 instance by executing 
"wsl --shutdown" and then reopening your WSL2 terminal.
EOF
