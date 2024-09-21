## Data backup

```sh
mkdir ~/Desktop/mnt
sudo btrfs subvolume delete /persist/.data-backup
sudo btrfs subvolume snapshot -r /persist/data /persist/.data-backup
cd /persist/.data-backup
gocryptfs -reverse -ro --exclude-from backup-exclude . ~/Desktop/mnt
cd ~/Desktop/mnt
aws configure
aws s3 sync --region us-west-2 --delete . s3://<bucket-name>
# Remove creds
cd ~
umount ~/Desktop/mnt
```

## Data restore

```sh
mkdir ~/Desktop/backup
mkdir ~/Desktop/mnt
cd ~/Desktop/backup
aws configure
aws s3 sync --source-region us-west-2 s3://<bucket-name> .
# Remove creds
gocryptfs -ro --exclude-from backup-exclude . ~/Desktop/mnt
cd ~/Desktop/mnt
# Use data
cd ~
umount ~/Desktop/mnt
rm -r ~/Desktop/backup_crypt
```
