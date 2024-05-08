echo Enter username:
read username

sudo userdel -r $username
sudo rm -rf /mnt/slurm_nfs/$username
sudo rm -rf /mnt/datasets_nfs/$username
