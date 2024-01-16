## Data backup

```sh
nix shell nixpkgs#awscli2
mkdir ~/Desktop/mnt
sudo btrfs subvolume rm /persist/.data-backup
sudo btrfs subvolume snapshot -ro /persist/data /persist/.data-backup
cd /persist/.data-backup
gocryptfs -reverse -ro --exclude-from backup-exclude . ~/Desktop/mnt
aws configure
cd ~/Desktop/mnt
aws s3 sync --delete . s3://<bucket-name>
# Remove creds
```
