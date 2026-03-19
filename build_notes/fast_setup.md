# Fast Guide W Scripts

## 1. VM Setup
follow the guide [vm setup](steps/01_vm_setup.md)

## 1. As root on host — partition the LFS disk
```bash
sudo bash scripts/01_setup/01_disk_partition.sh /dev/sdb
```

## 2. As root on host — create user + dirs + shell env
```bash
sudo bash scripts/01_setup/02_env_setup.sh
```

## 3. Switch to lfs, download all sources
```bash
sudo su - lfs
bash scripts/01_setup/03_download_sources.shs
```

## 4. Verify host tools
```bash
bash scripts/01_setup/04_version_check.sh
bash scripts/02_build/01_check_env.shs
```

## 5. Build the entire cross-toolchain (or resume from step N)
```bash
bash scripts/02_build/02_run_toolchain.sh
# bash scripts/02_build/02_run_toolchain.sh 3   ← resume from step 3
```