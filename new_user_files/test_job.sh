#!/bin/bash
#SBATCH --job-name=test                                      # create a short name for your job
#SBATCH --partition=smallcard                                # smallcard has 8GB GPUs available. Other, larger partitions are available. Ask Mike (mstachow@uwaterloo.ca)
#SBATCH --nodes=1                                            # node count - unles you are VERY good at what you're doing, you should keep this as-is
#SBATCH --ntasks=1                                           # total number of tasks across all nodes - you only have 1 node, so you only have 1 task. Leave this.
#SBATCH --cpus-per-task=1                                    # cpu-cores per task (>1 if multi-threaded tasks) - play with this number if you are using a lot of CPU, but most people are using these machines for GPU only
#SBATCH --gres=gpu:1                                         # most machines have a single GPU, so leave this as-is. If you are on a dual GPU partition, this can be changed to --gres=gpu:2 to use both
#SBATCH --mem-per-cpu=12G                                    # memory per cpu-core - unless you're doing something obscene the default here is fine. This is RAM, not VRAM, so it's like storage for your dataset
#SBATCH --time=00:10:00                                      # total run time limit (HH:MM:SS) - Good idea to keep it to what you need, in case your job goes off the rails and you can't stop it, this will stop it automatically 
#SBATCH --output /mnt/slurm_nfs/replaceme/job_output/%j.out   # location of your job output files

#If you are using your own custom venv, replace mine with yours. Otherwise, stick to this default. It has torch, transformers, accelerate and a bunch of others. I'm happy to add more common libraries
source /local/transformers/bin/activate

#Trust. If you're using anything from huggingface, leave these lines it. These don't affect your job at all anyway, so really...just leave it in.
export TRANSFORMERS_CACHE=/local/cache
export HF_HOME=/local/cache
export SENTENCE_TRANSFORMERS_HOME=/local/cache

#This is where you run your actual code. Here, we are just running python. Theoretically other stuff should work as well. If you are finding that the compute nodes don't have what you need, contact Mike.
python3 test.py

#you activated a venv, so deactivate it when you're done
deactivate
