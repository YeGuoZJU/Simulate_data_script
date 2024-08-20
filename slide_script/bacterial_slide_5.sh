#! /bin/bash
#BATCH --job-name=selected_slide
#SBATCH --partition=fat-2
#SBATCH --nodes=1
#SBATCH --cpus-per-task=96
#SBATCH --ntasks-per-node=1
#SBATCH --output job-%j.out
#SBATCH --error job-%j.err

set -o errexit

#Define the path folder
Input="/home/littt/share/hongh/GenLib/20230321/refseq/bacteria/GCF_noplasmid"
Output="/home/yeguo/share/yeguo/simulate_GCF_noplasmid_slide_5_0805/result_table_slide_5_0805"

#Read sample name

cat ${Output}/bacterial_final_slide_5.txt | xargs -P 96 -I {} bash -c "mkdir -p ${Output}/{}"

cat ${Output}/bacterial_final_slide_5.txt | xargs -P 96 -I {} bash -c "gunzip -c ${Input}/{}*.fna.gz > ${Output}/{}/{}.fna"

cat ${Output}/bacterial_final_slide_5.txt | xargs -P 96 -I {} bash -c "sed -i -E '/^>/!s/[^ATCG]//g' ${Output}/{}/{}.fna"

cat ${Output}/bacterial_final_slide_5.txt | xargs -P 96 -I {} bash -c "/home/yeguo/biosoft/seqkit sliding -s 5 -W 150 ${Output}/{}/{}.fna -o ${Output}/{}/{}_sliding.fna"

cat ${Output}/bacterial_final_slide_5.txt | xargs -P 96 -I {} bash -c "~/biosoft/seqtk/seqtk seq ${Output}/{}/{}_sliding.fna -F 'A' > ${Output}/{}/{}_sliding.fq"

