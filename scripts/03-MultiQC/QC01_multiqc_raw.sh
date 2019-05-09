#!bin/bash

############################################################################################################
#NAME SCRIPT: MultiQC.sh
#AUTHOR: Christophe van den Eynde
#RUNNING MultiQC
#USAGE: ./runMultiQC.sh
############################################################################################################

#VARIABLES--------------------------------------------------------------------------------------------------
# inputFolder = /home/data/${id}/01_QC-Rawdata/QC_FastQC/
# outputFolder = /home/data/${id}/01_QC-Rawdata/QC_MultiQC
#----------------------------------------------------------------------------------------------------------

#MultiQC PRE-START------------------------------------------------------------------------------------------
#Fix possible EOL errors in sampleList.txt
dos2unix /home/data/sampleList.txt
#-----------------------------------------------------------------------------------------------------------

#===========================================================================================================
# 1) MULTIQC FULL RUN
#===========================================================================================================

# CREATE FOLDERS--------------------------------------------------------------------------------------------
# create temp folder in container (will automatically be deleted when container closes)
mkdir -p /home/fastqc-results
# create outputfolder MultiQC full run Rawdata
run="RUN_"`date +%Y%m%d`
mkdir -p /home/data/QC_MultiQC/${run}/QC-Rawdata
#-----------------------------------------------------------------------------------------------------------

# COLLECT FASTQC DATA---------------------------------------------------------------------------------------
# collect all fastqc results of the samples in this run into this temp folder
for id in `cat /home/data/sampleList.txt`; do
      cp -r /home/data/${id}/01_QC-Rawdata/QC_FastQC/* /home/fastqc-results/
done
#-----------------------------------------------------------------------------------------------------------

# MultiQC FULL RUN------------------------------------------------------------------------------------------
echo -e "\nStarting MultiQC on Full RUN\n"
echo "----------"
multiqc /home/fastqc-results/ \
-o /home/data/QC_MultiQC/${run}/QC-Rawdata \
2>&1 | tee -a /home/data/QC_MultiQC/${run}/QC-Rawdata/stdout_err.txt;
echo "----------"
echo -e "\nDone, output file can be found in: /home/data/QC_MultiQC/QC-Rawdata\n"
#-----------------------------------------------------------------------------------------------------------

#===========================================================================================================
# 2) MULTIQC ON EACH SAMPLE (SEPARATELY)
#===========================================================================================================

#EXECUTE MultiQC--------------------------------------------------------------------------------------------
for id in `cat /home/data/sampleList.txt`; do
      #CREATE OUTPUTFOLDER IF NOT EXISTS
      cd /home/data/${id}/01_QC-Rawdata/
      mkdir -p QC_MultiQC/
      #RUN MultiQC
      echo -e "\nStarting MultiQC on: /home/data/${id}/01_QC-Rawdata/QC_FastQC/\n"
      echo "----------"
      multiqc /home/data/${id}/01_QC-Rawdata/QC_FastQC/ \
      -o /home/data/${id}/01_QC-Rawdata/QC_MultiQC \
      2>&1 | tee -a /home/data/${id}/01_QC-Rawdata/QC_MultiQC/stdout_err.txt;
      echo "----------"
      echo -e "\nDone, output file can be found in: /home/data/${id}/01_QC_Rawdata/QC_MultiQC\n"
done
#-----------------------------------------------------------------------------------------------------------

