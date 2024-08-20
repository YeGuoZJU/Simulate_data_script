#! /bin/bash
#SBATCH --job-name=fungi_GCF_simulate
#SBATCH --partition=cpu
#SBATCH --nodes=1
#SBATCH --cpus-per-task=48
#SBATCH --ntasks-per-node=1
#SBATCH --output job-%j.out
#SBATCH --error job-%j.err

set -o errexit

#Define the path folder
Input="/home/littt/share/hongh/GenLib/20230321/refseq/fungi/GCF"
Output="/home/yeguo/share/yeguo/simulate_data/fungi_GCF_10/data"

#Read sample name

cat ${Output}/fungi_GCF_10_sample.txt | xargs -P 48 -I {} bash -c "mkdir -p ${Output}/{}"

cat ${Output}/fungi_GCF_10_sample.txt | xargs -P 48 -I {} bash -c "gunzip -c ${Input}/{}.fna.gz > ${Output}/{}/{}.fna"

cat ${Output}/fungi_GCF_10_sample.txt | xargs -P 48 -I {} bash -c "sed -i -E '/^>/!s/[^ATCGN]/N/g' ${Output}/{}/{}.fna"

cat ${Output}/fungi_GCF_10_sample.txt | xargs -P 48 -I {} bash -c "/home/yeguo/biosoft/art_bin_MountRainier/art_illumina --noALN -ss HS25 -i ${Output}/{}/{}.fna -p -l 150 -m 500 -f 10  -s 10 -o ${Output}/{}/{}_"




