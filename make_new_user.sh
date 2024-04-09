is_valid_username() {
    if [[ "$1" =~ ^[a-zA-Z_]+$ ]]; then
        return 0
    else
        return 1
    fi
}


echo Enter username:
while read username; do
    if is_valid_username "$username"; then
        break
    else
        echo Username must contain only alphabets or underscores
        echo Enter username:
    fi
done


sudo adduser "$username"

mkdir /mnt/slurm_nfs/"$username"
mkdir /mnt/slurm_nfs/"$username"/job_output
mkdir /mnt/datasets_nfs/"$username"

cp /mnt/slurm_nfs/watai_admin/compute/new_user_files/test* /mnt/slurm_nfs/"$username"
sed -i "s/replaceme/$username/g" /mnt/slurm_nfs/"$username"/test_job.sh

sudo chown -R "$username":"$username" /mnt/slurm_nfs/"$username"
sudo chown -R "$username":"$username" /mnt/datasets_nfs/"$username"

