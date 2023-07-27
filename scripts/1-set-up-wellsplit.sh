## commands used to make a list of files to send to demultiplexing script
## 2-run-well-split.sh

ls *R1*.fastq > listR1
ls *R2*.fastq > listR2
ls *-R1* | sed 's/-R1[^=&]*//g' | paste listR1 listR2 - > file-list.txt

