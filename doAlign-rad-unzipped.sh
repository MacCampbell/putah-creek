#!/bin/bash -l

#Requires a tab delimited list of paired end files with desired name (list, $1)
#SRR1613242_1  SRR1613242_2 SRR1613242

#Requires a path to indexed reference genome (ref, $2)

#bash ../../doAlign-rad-unzipped.sh to-align.txt /home/maccamp/genomes/chinook-2/GCF_018296145.1_Otsh_v2.0_genomic.fna 

list=$1
ref=$2

wc=$(wc -l ${list} | awk '{print $1}')

x=1
while [ $x -le $wc ] 
do
        string="sed -n ${x}p ${list}" 
        str=$($string)

        var=$(echo $str | awk -F"\t" '{print $1, $2, $3}')   
        set -- $var
        c1=$1
        c2=$2
        c3=$3

       echo "#!/bin/bash -l
       module load bwa/0.7.17
       bwa mem $ref ${c1}.fastq ${c2}.fastq | samtools view -Sb | samtools sort - -o ${c3}.sort.bam
       samtools index ${c3}.sort.bam
       samtools view -f 0x2 -b ${c3}.sort.bam | samtools rmdup - ${c3}.sort.flt.bam
       samtools index ${c3}.sort.flt.bam
       reads=\$(samtools view -c ${c3}.sort.bam)
       rmdup=\$(samtools view -c ${c3}.sort.flt.bam)
       depth=\$(samtools depth -a ${c3}.sort.flt.bam | awk '{sum+="\$3"} END {print sum/NR}' )
       echo \"${c3},\${reads},\${rmdup},\${depth}\"  > ${c3}.stats" > ${c3}.sh
       sbatch -p bigmemm -t 2-10:00:00 --mem=8G ${c3}.sh

       x=$(( $x + 1 ))

done


