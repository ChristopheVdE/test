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
Threads=`cat /home/Pipeline/environment.txt | grep "Threads="`
Threads=${Threads#"Threads="}
# inputfolder = /home/Pipeline/data/${id}/02_Trimmomatic
# outputFolder = /home/Pipeline/data/${id}/03_QC-Trimmomatic_Paired/QC_fastqc
#-----------------------------------------------------------------------------------------------------------

#FASTQC PRE-START-------------------------------------------------------------------------------------------
#Fix possible EOL errors in sampleList.txt
dos2unix /home/Pipeline/sampleList.txt
echo
#-----------------------------------------------------------------------------------------------------------

#RUN FASTQC-------------------------------------------------------------------------------------------------
echo "Starting FastQC with ${Threads} threads"
for id in `cat /home/Pipeline/sampleList.txt`; do
     #CREATE OUTPUTFOLDER IF NOT EXISTS
     mkdir -p /home/Pipeline/${id}/03_QC-Trimmomatic_Paired/QC_FastQC
     #RUN FASTQC
     for i in $(ls /home/Pipeline/${id}/02_Trimmomatic | grep _P.fastq.gz); do
          echo -e "STARTING FastQC on paired reads of ${i} \n";
          fastqc --extract \
          -t ${Threads} \
          -o /home/Pipeline/${id}/03_QC-Trimmomatic_Paired/QC_FastQC \
          /home/Pipeline/${id}/02_Trimmomatic/${i} \
          2>&1 | tee -a /home/Pipeline/${id}/03_QC-Trimmomatic_Paired/QC_FastQC/stdout_err.txt ;
          echo -e "\n ${i} FINISHED \n";
     done
done
#------------------------------------------------------------------------------------------------------------
