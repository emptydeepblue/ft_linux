# Fast Guide W Scripts

## 1. VM Setup
follow the guide [vm setup](steps/01_vm_setup.md)

## 1. As root on host — partition the LFS disk
```bash
sudo bash scripts/setup/01_disk_partition.sh /dev/sdb
```

## 2. As root on host — create user + dirs + shell env
```bash
sudo bash scripts/setup/02_env_setup.sh
```

## 3. Switch to lfs, verify host tools
```bash
sudo su - lfs
bash scripts/version-check.sh
```

## 4. Download all sources
```bash
bash scripts/setup/03_download_sources.sh
```

## 5. Build the entire cross-toolchain (or resume from step N)
```bash
bash scripts/run_toolchain.sh
# bash scripts/run_toolchain.sh 3   ← resume from step 3
```