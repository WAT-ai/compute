
# Nebula Guide
A guide to access, set up, and use the ECE Nebula GPU cluster. This is a [slurm](https://slurm.schedmd.com/overview.html)-managed Ubuntu Linux system. If you've never used Linux command line before, [here's a starter guide to Ubuntu](https://ubuntu.com/tutorials/command-line-for-beginners#1-overview). This guide will cover basics of using slurm to run jobs on the cluster.

Throughout this guide:
- `username` and `password` refer to the username and password given to you by an admin.
- `jobid` refers to your job's id, which is generated when you'll execute a job.
- `envname` refers to the name of your python3 environment. You choose this.

_Note: much of the following text was lifted from Professor Mike's ECE_NEBULA_NON_ADMIN_USERGUIDE.pdf_

# Set up
You must do this set up only once.
1. Contact an admin for a `username` and `password`. You can reach admins in the compute channel on the WAT.ai Discord server.
2. Set up and connect to the UW VPN. [Link](https://uwaterloo.ca/mechanical-mechatronics-engineering-information-technology/virtual-private-network-vpn) to guide.
3. SSH into your account. It is up to you how to do this.
    * A good option is VS code remote connection [here](https://code.visualstudio.com/docs/remote/ssh).
        * Install the extension.
        * Press Ctrl+Shift+P.
        * Start typing and select: Remote-SSH: Connect to Host
        * Enter `username@ece-nebula07.eng.uwaterloo.ca`
        * Enter your password when prompted.
        * Enter Linux as the platform if prompted.
4. You are now logged into the `/home/username` directory. However, this is not where jobs are executed from. cd to `mnt/slurm_nfs/username`. This is your directory in the network file system (NFS). 

  
# Running a Test Job (Optional, but recommended for first time)
1. If this is your first time logging in, you will see two files already in the directory:
    * `test.py`: A sample python file.
    * `test_job.sh`: A sample bash for executing a job.
2. Run a test job by executing `sbatch test_job.sh`. You'll see some confirmation your job has been submitted: `Submitted batch job jobid`
3. Your job has been submitted to a compute node for execution. View your job status in the queue by running `squeue`. This will show you the jobs currently running. One of them should be yours. The output looks like:
    * ```text
      JOBID PARTITION NAME USER ST TIME NODES NODELIST(REASON)
      20356 smallcard test user_name R 0:02 1 ece-nebula06
      ```
    * Note that the test task is short, so it may have already finished running if you take long to run `squeue`.
4. To get constantly updated info, run `watch -n 1 squeue`. This will continually call squeue every second. Execute the watch and keep it open until your job goes away. This indicates it is finished. Use CTRL+C to exit the watch.

5. Your code is running on a different computer than the one you are SSH'ed into, hence, you won't see your code output in the terminal. The stdout output (print statements and errors from code execution) is saved to .out files. These files have name: `slurm-jobid.out`. The location of these files depends on your SLURM configuration, but it is likely they are in `mnt/slurm_nfs/username/job_output/`.
6. You can execute `cat name-of-your-out-file.out` to see the stdout of your job.

# Running Jobs
Above you ran an example job. However, to run actual jobs, you'll need to set up your environment (like libraries) and copy over your code files.
1. As outlined in the set up section, connect to VPN, SSH, and cd into `mnt/slurm_nfs/username`.
2. Create a python virtual env. `python3 -m venv envname`
3. Activate the environment. `source envname/bin/activate`
4. Install packages. You should use `pip` or another lightweight package manager to install requirements (i.e. avoid conda).
    * If you have a `requirements.txt` file `pip install -r requirements.txt`
    * You can run any pip commands you want. For example, installing PyTorch `pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118`
5. Get your code. You can create or copy files. The easiest and most robust method is to git clone a repo with all the code you need.
6. Storing data and results.
    * If applicable, load your data onto the cluster. This is highly dependent on where your data is stored and how it is accessed. If you need help, reach out in the compute channel on the WAT.ai discord.
    * Small files (e.g. csvs, logs, .out files, etc.) can be stored in `mnt/slurm_nfs/username/`
    * Large files (e.g. datasets, big model checkpoints) should be stored in `/datasets_nfs/username/`
    * *THIS CLUSTER IS NOT A DATA STORE. LARGE FILES NOT ACCESSED FOR OVER A WEEK ARE SUBJECT TO DELETION*. It is your responsibility to ensure that your data, trained AI models, and other large files are stored in a safe place.
7. Modify scripts to match paths on the cluster. (paths for data, logs, results, configs, etc)
8. Configure your job shell script. You can use the `test_job.sh` file as a starting point. You have to:
    * Configure SLURM parameters. Refer to Requesting Resources below for more details.
    * Choose and activate your python venv.
    * Define any environment variables.
    * If applicable, do any other set up (examples: spin up a database if you are using one).
    * Run your code. For ML workloads this will likely be a .py script, but it could technically be anything.
    * If applicable, turn off and clean up any other running applications or resources.
    * Deactivate the python venv.
9. Execute `sbatch name-of-your-slurm-bash-script.sh`. You'll see confirmation your job has been submitted: `Submitted batch job jobid`
10. As outlined earlier, you can use `squeue` and `watch -n 1 squeue` to monitor your task.
11. As outlined earlier, the stdout of your job is saved to .out.
   * The files have names: `slurm-jobid.out`.
   * The location of these files depends on your SLURM configuration, but it is likely they are in `mnt/slurm_nfs/username/job_output/`.
   * You can execute `cat name-of-your-out-file.out` to see the stdout of your job.
12. Run `tail -f name-of-your-out-file.out` after executing your job to see logs in real time. Beware that this command may also print buffers that have nothing do with your code.

# Understanding the Cluster

The ece-nebula cluster is made up of two types of computers, from the user’s perspective: the login node and the compute nodes. Users are allowed to log in only to the login node, which node does not have any GPUs and should never perform computation for your job.

When you submit a job, the login node searches for a compute node that meets your resource requirements, and if one is found it will allocate that node to your job. If none are currently available but your resource request is valid, your job gets put into the queue and will run once resources are free. Finally, if no node exists on the cluster that meets your requirements, you will see an error when you try to submit the job.

We’ll go into requesting resources in more detail below, but first we need to get something important out of the way:

## The Network File Share
Compute nodes and the login node are physically different computers. All of your work, files, and datasets must be on a networked file share in order for the login node and the compute nodes to perform your job. For instance, if you were to put a python script you wanted to run on a folder that the compute node can’t see, there is no way for the node to run your job, and you will see an error in the output file.

This is why we had to navigate to the specific folder. The folder `mnt/slurm_nfs/user_name` is your folder that is accessible to all nodes in the cluster. You can make subfolders in this folder, but you need to make sure that all of your code goes there. The administrators of the cluster will periodically remove accounts that have not been accessed in six months. Therefore, it is best not to store data on this cluster long-term.

### The /datasets_nfs Share
The folder `mnt/slurm_nfs` physically sits on the login node, which (as of January 2024) has limited storage of about 400GB. Although that may sound like a lot, for a multi-user system like this one it is in fact very small.

If you are going to work with large datasets (even a few GB is considered “large” given the number of users), you should put your datasets into the `/datasets_nfs` folder instead of `mnt/slurm_nfs`. This is as simple as copying the dataset into the `/datasets_nfs` folder from your local machine.

The `/datasets_nfs` folder is also networked to all of the compute nodes and the login node. The major difference is that this folder sits on a computer with 1TB of storage space, and cluster administrators will clean it more frequently – any file not accessed within the last week may be subject to deletion if the drive gets full. Therefore, `/datasets_nfs` should never be used for long-term storage.

In the future we hope to expand the storage capacity of the cluster, but you should be aware that the cluster will never be a place to store huge amounts of data and AI models. We simply don’t have the resources to provide that service to all UW engineering undergrads.

### Why Jobs Load Slowly
Since everything is on the NFS, jobs, models, and data must be transferred to the compute node you are working on before the job can start running. For this reason, running a job that takes a lot of data can take quite a while. Once the job is fully loaded, however, it will run as fast as the GPU can run. Therefore, it is best to use the cluster to load jobs that process a batch of inputs at once, rather than only a single input. For instance, the test job, test_t5.py, is in fact quite poorly set up, because it loads a model, runs a single query on it, and ends. This is not ideal, because the loading happens over the network.

Instead, you should consider processing a large number of inputs at once. A simple way to do this is to create a file or a folder on the /datasets_nfs share, and process all of the inputs at once.

# Requesting Resources
SLURM’s purpose is to allocate nodes to jobs (perhaps more accurately, jobs to nodes). The first lines in the submission script tell SLURM the type of resources you need. Whenever two jobs request the same resources, SLURM schedules the first to arrive. The later-arriving job is held in a job queue until the first-to-arrive job is complete.

To make job allocation easier, we have combined the compute nodes into partitions based on VRAM. The partitions have names to remember them. They are:
- smallcard: 2 nodes with 8GB VRAM each.
- midcard: 1 node with 20GB VRAM (midcard will be expanding to 2 nodes in S2024)
- dualcard: 2 nodes with 2 GPUs, each with 20GB VRAM
- bigcard: (Planned for Feb 2024) 1 node with 2 GPUs, each with 48GB VRAM

Open your job submission script (if you’re working with the starter scripts, this would be test_job.sh).
The comments after the lines starting with #SBATCH indicate the resources you are requesting.
There are a few of interest:
- `#SBATCH --partition=smallcard` this is the partition you want to work on. Which partition your job goes to determines the resources available to you
- `#SBATCH --cpus-per-task=1` for a job that is CPU-heavy, you can change this to a higher number. Generally, you can allocate all of the available CPUs of a node, but SLURM usually gives one to the OS so it’s best to allocate a few less than maximum. For most AI workloads, a single CPU is fine since the compute happens on GPU.
    * smallcard nodes have 4 CPUs
    * all other partitions’ nodes have 24 CPUs
- `#SBATCH --gres=gpu:1` if you are running a job on smallcard or midcard, all nodes have only 1 GPU, so leave this unchanged. If you are running a job on the other partitions, they have dual GPUs, so you can increase this to 2 if you are using both GPUs. Note: if you are not using both GPUs, setting this to 1 lets SLURM allocate someone else’s single-GPU job to the other GPU.
- `#SBATCH --mem-per-cpu=12G` this is allocating 12GB of RAM (not VRAM) to your job. This is best set to 1.5x the VRAM of your GPU, since many AI workloads will first load data into the RAM then move it to VRAM, and the OS needs some as well. All nodes have at least 1.5x their VRAM in normal RAM.
- `#SBATCH --time=00:10:00` time, in HH:MM:SS format. You should set this to a reasonable, finite number. When in doubt, make it bigger, but do not make it infinite. Most of the time your job will finish before it times out, but if something goes wrong and it gets stuck it is best to automatically end the job.

# How to Choose Resources
You may have never had to think about the resources you need for a job before – normally, if you only have access to a single computer, you just use what’s there.

It’s not a huge deal if you request the wrong resources, but it’s generally better to request more resources than less until you are certain of what your job needs. This is because running a smaller job on a bigger machine will succeed, but be wasteful, while running a job that is too big for the machine will end in an error.

Normally, when running an AI workload, I ask myself the following questions:
- How big is the AI model? Normally this is well-known, and can range from a few MB to tens of GB.
- Do I need a lot of CPU? Normally you don’t, but if your job requires, say, preprocessing a large dataset then loading it into a GPU for learning, you may use a lot of CPU
- How long will this job run for? The only thing that teaches you this is experience. Most of my AI jobs either run for under a minute or several hours, with very little in between.

You should try your best to allocate as few resources as possible to your job, so that if someone who needs more resources than you wants to run a job they are able to. However, the cluster is for learning, so it’s OK if you allocate more than you need.

# Checking if Resources are Available
There are two SLURM commands that are useful to check if resources are available. For instance, if you want to run a small job that can easily fit on a smallcard machine, but both machines are in use and no other machines are, you can request resources on a bigger machine instead. To see what is available, you can use the commands `sinfo` and `squeue`.
- `sinfo` tells you the state of the machines. Any machine in an “idle” state can be allocated, otherwise it is either already in use or it is down
- `squeue` tells you how many jobs are in the queue for the partition. If all nodes are allocated, it can give you an idea of where to submit your job. For instance, if all nodes are allocated but `squeue` shows that midcard has only one job and all of the others have ten jobs, it makes sense to allocate to midcard, since it is likely that you will get to run your job sooner.

# The scancel Command is your Friend
If you start a long-running job but then realize that something is wrong (you downloaded the wrong dataset, say), you can cancel a job by its ID or you can cancel all jobs belonging to your username.
- Cancel a job by its id: `scancel jobid` (for instance, to cancel job 1234, `scancel 1234`)
- Cancel a job by your username: `scancel -u username`. Note that this cancels ALL of your jobs, so if you have submitted more than one it will stop them all
