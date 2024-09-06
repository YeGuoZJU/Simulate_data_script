

# 问题：模拟数据库中基因组的双端测序数据，并将相同的taxid的assembly放在一个文件夹下，同时合并这些assembly至一个双端测序文件，并以taxid号命名

tree -L 3 | head -n 22
.
|-- 100
|   |-- 100_1.fq.gz
|   |-- 100_2.fq.gz
|   `-- GCF_004339465.1
|       |-- GCF_004339465.1.fna
|       |-- GCF_004339465.1_1.fq
|       `-- GCF_004339465.1_2.fq
|-- 100053
|   |-- 100053_1.fq.gz
|   |-- 100053_2.fq.gz
|   `-- GCF_000243815.2
|       |-- GCF_000243815.2.fna
|       |-- GCF_000243815.2_1.fq
|       `-- GCF_000243815.2_2.fq
|-- 1000566
|   |-- 1000566_1.fq.gz
|   |-- 1000566_2.fq.gz
|   `-- GCF_014137975.1
|       |-- GCF_014137975.1.fna
|       |-- GCF_014137975.1_1.fq
|       `-- GCF_014137975.1_2.fq


# 以细菌的模拟数据为例，来说明此次数据的模拟流程

# 细菌基因组的路径 /home/littt/share/hongh/GenLib/20240416/refseq/bacteria/GCF_CompressNRSP

# STEP 1 提取模拟基因组的名称
ls *.gz | awk -F '.fna' '{print $1}' > ~/share/yeguo/simulate_GenLib_CompressNRSP_art_100_0904/bacterial/bacterial_GCF_CompressNRSP_name.txt

awk -F "_" '{print$1"_"$2}' bacterial_GCF_CompressNRSP_name.txt > bacterial_GCF_CompressNRSP.txt

# STEP 2 提取基因组和对应taxid的名称
awk -F "\t" 'NR> 2 {print$1,$7}' assembly_summary_CompressNRSP.tsv >  ~/share/yeguo/simulate_GenLib_CompressNRSP_art_100_0904/bacterial/data/name_taxid.txt

# STEP 3 提取taxid的名称
awk -F " " '{print$2}' name_taxid.txt > taxid.txt

# STEP 4 生成模拟数据
sbatch bacterial_art_100.sh

# STEP 5 将相同的taxid对应的模拟数据放在一个文件夹下 （一个taxid可能对应多个GCF文件）
cat bacterial_GCF_CompressNRSP.txt | while read id
do
newname=$(grep -w "${id}" name_taxid.txt| awk '{print $2}')
if [ ! -d "${newname}" ]
then
mkdir "${newname}"
fi
mv "${id}" "./${newname}"
done

# 以下步骤可选，目的是将一个taxid下的所有的assembly的基因组合并成一个双端文件
# STEP 6 将每一个assembly下的GCF文件夹下的双端数据cp到上一层目录，便于后续压缩
 # 单个循环
cat bacterial_GCF_CompressNRSP.txt | while read id
do
newname=$(grep -w "${id}" name_taxid.txt| awk '{print $2}')
cp ./${newname}/${id}/*.fq ./${newname}
done

# xargs并行
cat bacterial_GCF_CompressNRSP.txt | xargs -I {} sh -c '
  id={}
  newname=$(grep -w "$id" name_taxid.txt | awk "{print \$2}")
  echo "cp ./$newname/$id/*.fq ./$newname" >> cp_xargs.txt
  '
# STEP 7 合并每一个taxid文件夹下的的双端数据到一个双端测序数据

# 因为是按照taxid文件合并，taxid里面会有重复的，所以在这一步的时候，需要去重复，不然会导致重复合并多个测序的文件
sort taxid.txt| uniq > uniq_taxid.txt

# 单个循环
cat uniq_taxid.txt | while read id
do
cat ~/share/yeguo/simulate_GenLib_CompressNRSP_art_100_0904/archaea/data/${id}/*_1.fq > ~/share/yeguo/simulate_GenLib_CompressNRSP_art_100_0904/archaea/data/${id}/${id}_1.fq
cat ~/share/yeguo/simulate_GenLib_CompressNRSP_art_100_0904/archaea/data/${id}/*_2.fq > ~/share/yeguo/simulate_GenLib_CompressNRSP_art_100_0904/archaea/data/${id}/${id}_2.fq
done

# xargs并行
cat uniq_taxid.txt | xargs -I {} -P 4 sh -c '
  id={}
  echo "cat ~/share/yeguo/simulate_GenLib_CompressNRSP_art_100_0904/bacterial/data/${id}/*_1.fq > ~/share/yeguo/simulate_GenLib_CompressNRSP_art_100_0904/bacterial/data/${id}/${id}_1.fq" >> cat_xargs.txt
  echo "cat ~/share/yeguo/simulate_GenLib_CompressNRSP_art_100_0904/bacterial/data/${id}/*_2.fq > ~/share/yeguo/simulate_GenLib_CompressNRSP_art_100_0904/bacterial/data/${id}/${id}_2.fq" >> cat_xargs.txt
  '

head cat_xargs.txt

# cat ~/share/yeguo/simulate_GenLib_CompressNRSP_art_100_0904/bacterial/data/100/*_1.fq > ~/share/yeguo/simulate_GenLib_CompressNRSP_art_100_0904/bacterial/data/100/100_1.fq
# cat ~/share/yeguo/simulate_GenLib_CompressNRSP_art_100_0904/bacterial/data/100053/*_1.fq > ~/share/yeguo/simulate_GenLib_CompressNRSP_art_100_0904/bacterial/data/100053/100053_1.fq
# cat ~/share/yeguo/simulate_GenLib_CompressNRSP_art_100_0904/bacterial/data/1000566/*_1.fq > ~/share/yeguo/simulate_GenLib_CompressNRSP_art_100_0904/bacterial/data/1000566/1000566_1.fq
# cat ~/share/yeguo/simulate_GenLib_CompressNRSP_art_100_0904/bacterial/data/1000568/*_1.fq > ~/share/yeguo/simulate_GenLib_CompressNRSP_art_100_0904/bacterial/data/1000568/1000568_1.fq
# cat ~/share/yeguo/simulate_GenLib_CompressNRSP_art_100_0904/bacterial/data/100/*_2.fq > ~/share/yeguo/simulate_GenLib_CompressNRSP_art_100_0904/bacterial/data/100/100_2.fq
# cat ~/share/yeguo/simulate_GenLib_CompressNRSP_art_100_0904/bacterial/data/100053/*_2.fq > ~/share/yeguo/simulate_GenLib_CompressNRSP_art_100_0904/bacterial/data/100053/100053_2.fq
# cat ~/share/yeguo/simulate_GenLib_CompressNRSP_art_100_0904/bacterial/data/1000566/*_2.fq > ~/share/yeguo/simulate_GenLib_CompressNRSP_art_100_0904/bacterial/data/1000566/1000566_2.fq
# cat ~/share/yeguo/simulate_GenLib_CompressNRSP_art_100_0904/bacterial/data/1000568/*_2.fq > ~/share/yeguo/simulate_GenLib_CompressNRSP_art_100_0904/bacterial/data/1000568/1000568_2.fq
# cat ~/share/yeguo/simulate_GenLib_CompressNRSP_art_100_0904/bacterial/data/1001240/*_1.fq > ~/share/yeguo/simulate_GenLib_CompressNRSP_art_100_0904/bacterial/data/1001240/1001240_1.fq
# cat ~/share/yeguo/simulate_GenLib_CompressNRSP_art_100_0904/bacterial/data/100134/*_1.fq > ~/share/yeguo/simulate_GenLib_CompressNRSP_art_100_0904/bacterial/data/100134/100134_1.fq




# STEP8 合并完成后，删除taxid文件夹下的

 cat bacterial_GCF_CompressNRSP.txt | xargs -I {} sh -c '
   id={}  
   newname=$(grep -w "$id" name_taxid.txt | awk "{print \$2}")
   echo "rm ~/share/yeguo/simulate_GenLib_CompressNRSP_art_100_0904/bacterial/data/$newname/${id}_*.fq" >> xargs_rm.txt
   '
nohup srun -c 96 -p fat-2 xargs -a xargs_rm.txt -I '%' -t -P 96 sh -c '%' &> rm_nohup &

# STEP 9  压缩文件
cat uniq_taxid.txt| while read id
  do
  cmd="pigz -p 1 ./${id}/*.fq"
  echo "$cmd" >> pigz_xargs.txt
  done