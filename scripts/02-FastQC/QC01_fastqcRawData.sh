#!/bin/bash

############################################################################################################
#NAME SCRIPT: runFastqc.sh
#AUTHOR: Tessa de Block
#DOCKER UPDATE: Christophe Van den Eynde
#RUNNING FASTQC
#USAGE: ./runFastqc.sh <number of threads>
############################################################################################################

#VALIDATE NR OF PARAMETERS----------------------------------------------------------------------------------
# parameters are provided by snakefile (hardcoded)
#-----------------------------------------------------------------------------------------------------------

#VARIABLES--------------------------------------------------------------------------------------------------
# inputFolder = /home/data/${id}/00_Rawdata
# outputFolder = /home/data/${id}/01_QC_rawdata/QC_FastQC
#-----------------------------------------------------------------------------------------------------------

#FASTQC PRE-START-------------------------------------------------------------------------------------------
#Fix possible EOL errors in sampleList.txt
dos2unix /home/data/sampleList.txt
echo
#-----------------------------------------------------------------------------------------------------------

#RUN FASTQC-------------------------------------------------------------------------------------------------
for id in `cat /home/data/sampleList.txt`; do
     #CREATE OUTPUTFOLDER IF NOT EXISTS
     mkdir -p /home/data/${id}/01_QC-Rawdata/QC_FastQC
     #RUN FASTQC
     for i in $(ls /home/data/${id}/00_Rawdata | grep fastq.gz); do
          echo -e "STARTING ${i} \n";
          fastqc --extract \
          -o /home/data/${id}/01_QC-Rawdata/QC_FastQC \
          /home/data/${id}/00_Rawdata/${i} \
          2>&1 | tee -a /home/data/${id}/01_QC-Rawdata/QC_FastQC/stdout_err.txt ;
          echo -e "\n ${i} FINISHED \n";
     done
done
#------------------------------------------------------------------------------------------------------------

