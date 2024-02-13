# Nebula Onboarding
A guide to access, set up, and use the ECE Nebula GPU cluster on campus.

Throughout this guide:
- `username` and `password` refer to the username and password given to you by an admin.
- `jobid` refers to your job's id, which is generated when you'll execute a job.
- `envname` refers to the name of your python3 environment. You choose this.


# Set up
You must do this set up only once.
1. Set up and connect to the UW VPN. [Link](https://uwaterloo.ca/mechanical-mechatronics-engineering-information-technology/virtual-private-network-vpn) to guide.
2. SSH into your account. It is up to you how to do this.
    * We recommend the VS code remote connection extension [here](https://code.visualstudio.com/docs/remote/ssh) as follows:
        * Install the extension.
        * Press Ctrl+Shift+P.
        * Start typing and select: Remote-SSH: Connect to Host
        * Enter `username@ece-nebula07.eng.uwaterloo.ca`
        * Enter your password when prompted.
        * Enter Linux as the platform if prompted.
3. You are now logged into the `/home/username` directory. However, this is not where jobs are executed from. cd to `/slurm_nfs/username`. This is your directory in the network file system (NFS). 

  
# Optional. Recommended if first time.
1. If this is your first time logging in, you will see two files already in the directory:
    * `test.py`: A sample python file.
    * `test_job.sh`: A sample bash for executing a job.
2. You can run a test job. Execute `sbatch test_job.sh`. You'll see some confirmation your job has been submitted like `Submitted batch job jobid`
3. Your job has been submitted to a compute node for execution. You can see your job status in the queue by running `squeue`. This will show you the jobs currently running, and you should see that one of them is yours. The ouput looks like:
    * ```text
      JOBID PARTITION NAME USER ST TIME NODES NODELIST(REASON)
      20356 smallcard test user_name R 0:02 1 ece-nebula06
      ```
    * Note that the test task is short, so it may have already finished running if you take long to run `squeue`.
4. To get constantly updated info, run `watch -n 1 squeue`. This will continually call squeue every second. Execute the watch and keep it open until your job goes away. This indicates it is finished. Use CTRL+C to exit the watch.

5. The stdout output (where you can see print statements and errors from code execution) of your job are saved to .out files. These files have name: `slurm-jobid.out`. Where these files are saved may vary, but it is likely they are in `/slurm_nfs/username/job_output/`.
6. You can execute `cat name-of-your-out-file` to see the stdout of your job.

# Running jobs
Above you ran an example job. However, to run actual jobs, you'll need to set up your environment (like libraries) and copy over your code files.
1. As outlined above, connect to VPN, SSH, and cd into `/slurm_nfs/username`.
2. Create a python virtual env. `python3 -m venv envname`
3. Activate the environment. `source envname/bin/activate`
4. Install packages. You can do this using pip or however else you want.
    * If you have a `requirements.txt` file `python -m pip install -r requirements.txt`
    * You can run any pip commands you want. For example, installing PyTorch `pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118`
5. Get your code. You can create or copy files. The easiest and most robust method is to git clone a repo with all the code you need.
6. Storing data and results
    * If applicable, get your data on the cluster. This is highly dependent on where your data is stored and how it is accessed. If you need help, reach out in the compute channel on the WAT.ai discord.
    * Small files (e.g. csvs, logs, .out files, etc.) can be stored in `/slurm_nfs/username/`
    * Large files (e.g. datasets, big model checkpoints) should be stored in `/datasets_nfs/username/`
    * *THIS CLUSTER IS NOT A DATA STORE. LARGE FILES NOT ACCESSED FOR OVER A WEEK ARE SUBJECT TO DELETION*. It is your responsibility to ensure that your data, trained AI models, and other large files are stored in a safe place.
8. Modify training scripts to match paths on the cluster. (paths for data, logs, results, configs, etc)
10. Set up your job shell script. You can rename and use the `test_job.sh` file.
    * TODO: fill in what this file should include. and how to configure that
    * TODO: Add steps to run job and do the tail trick
    * TODO: add information on how all this works (cop paste from prof mikes stuff)
    * TODO: test these steps
