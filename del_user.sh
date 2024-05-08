echo Enter username:
read username

sudo del userdel -r $username
sudo rm -rf /mnt/slurm_nfs/$username
sudo rm -rf /mnt/datasets_nfs/$username
