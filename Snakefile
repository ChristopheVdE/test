#find system-type
import platform
OS=platform.platform()

# change the separator depending on the system
if 'Windows' in OS == False:
    sep = '/'
    print("UNIX based system detected ({}), changing separator to {}".format(OS, sep))
else:
    sep = '\\'
    print("Windows based system detected ({}), changing path separator to {}".format(OS, sep))


# ask for input directory
import os
origin = input("Input the full path/location of the folder with the raw-data to be analysed:\n").replace('/',sep)
print("origin={}".format(origin))

# get current directory
location = os.getcwd().replace('/',sep)
print("location={}".format(location))

# creating sample-list (has file extensions)
samples_ext = os.listdir(origin)

#removing file extensions for samples_ext
samples = []
for sample_ext in samples_ext:
        samples.append(sample_ext.replace('.fastq.gz', ''))

#--------------------------------------------------------------------------

rule all:
    input:
        location+("/data/01_QC-Rawdata/QC_MultiQC/multiqc_report.html").replace('/',sep),
        location+("/data/03_QC-Trimmomatic/QC_MultiQC/multiqc_report.html").replace('/',sep)
        #"directory(data/04_SPAdes/*)"

#--------------------------------------------------------------------------
# Pipeline step1: copying files from original raw data folder to data-folder of current analysis

rule copy_files:
    input: 
        expand(origin+("/{sample_ext}").replace('/',sep),sample_ext=samples_ext)
    output:
        expand(location+("/data/00_Rawdata/{sample_ext}").replace('/',sep),sample_ext=samples_ext)
    message:
        "Please wait while the files are being copied"
    shell:
        "docker run -it --mount src={origin},target=/home/rawdata/,type=bind --mount src={location},target=/home/Pipeline/,type=bind christophevde/ubuntu_bash:1.0 /home/Scripts/01_copy_rawdata.sh"
    
#--------------------------------------------------------------------------
# Pipeline step2: running fastqc on the raw-data in the current-analysis folder

rule fastqc_raw:
    input:
        expand(location+("/data/00_Rawdata/{sample_ext}").replace('/',sep),sample_ext=samples_ext)
    output:
        expand(location+("/data/01_QC-Rawdata/QC_fastqc/{sample}_fastqc.html").replace('/',sep),sample=samples)
    message:
        "Analyzing raw-data with FastQC using Docker-container fastqc:2.0"
    shell:
        "docker run -it --mount src=({location}/data).replace('/',sep),target=/home/data/,type=bind christophevde/fastqc:2.0 /home/Scripts/QC01_fastqcRawData.sh"

#--------------------------------------------------------------------------
# Pipeline step3: running multiqc on the raw-data in the current-analysis folder

rule multiqc_raw:
    input:
        expand(location+("/data/01_QC-Rawdata/QC_fastqc/{sample}_fastqc.html").replace('/',sep),sample=samples)
    output:
        ("{location}/data/01_QC-Rawdata/QC_MultiQC/multiqc_report.html").replace('/',sep)
    message:
        "Analyzing raw-data with MultiQC using Docker-container multiqc:2.0"
    shell:
        "docker run -it --mount src=({location}/data).replace('/',sep),target=/home/data/,type=bind christophevde/multiqc:2.0 /home/Scripts/QC01_multiqc_raw.sh"

#--------------------------------------------------------------------------
# Pipeline step5: Trimming

rule Trimming:
    input:
        expand(location+("/data/00_Rawdata/{sample_ext}").replace('/',sep),sample_ext=samples_ext),
        location+("/data/01_QC-Rawdata/QC_MultiQC/multiqc_report.html").replace('/',sep)
    output:
        expand(location+("/data/02_Trimmomatic/{sample}_P.fastq.gz").replace('/',sep),sample=samples),
        expand(location+("/data/02_Trimmomatic/QC_fastqc/{sample}_U.fastq.gz").replace('/',sep),sample=samples)
    message:
        "Trimming raw-data with Trimmomatic v0.39 using Docker-container trimmomatic:1.1"
    shell:
        "docker run -it --mount src=({location}/data).replace('/',sep),target=/home/data/,type=bind christophevde/trimmomatic:1.1 /home/Scripts/02_runTrimmomatic.sh"

#--------------------------------------------------------------------------
# Pipeline step5: FastQC trimmed data

rule fastqc_trimmed:
    input:
        expand(location+("/data/02_Trimmomatic/{sample}_P.fastq.gz").replace('/',sep),sample=samples),
        expand(location+("/data/02_Trimmomatic/QC_fastqc/{sample}_U.fastq.gz").replace('/',sep),sample=samples)
    output:
        expand(location+("/data/03_QC-Trimmomatic/QC_fastqc/{sample}_U_fastqc.html").replace('/',sep),sample=samples),
        expand(location+("/data/03_QC-Trimmomatic/QC_fastqc/{sample}_P_fastqc.html").replace('/',sep),sample=samples)
    message:
        "Analyzing trimmed-data with FastQC using Docker-container fastqc:2.0"
    shell:
        "docker run -it --mount src=({location}/data).replace('/',sep),target=/home/data/,type=bind christophevde/fastqc:2.0 /home/Scripts/QC02_fastqcTrimmomatic.sh"

#--------------------------------------------------------------------------
# Pipeline step6: MultiQC trimmed data

rule multiqc_trimmed:
    input:
        expand(location+("/data/03_QC-Trimmomatic/QC_fastqc/{sample}_U_fastqc.html").replace('/',sep),sample=samples),
        expand(location+("/data/03_QC-Trimmomatic/QC_fastqc/{sample}_P_fastqc.html").replace('/',sep),sample=samples)
    output:
        ("{location}/data/03_QC-Trimmomatic/QC_MultiQC/multiqc_report.html").replace('/',sep)
    message:
        "Analyzing trimmed-data with MultiQC using Docker-container multiqc:2.00"
    shell:
        "docker run -it --mount src=({location}/data).replace('/',sep),target=/home/data/,type=bind christophevde/multiqc:2.0 /home/Scripts/QC02_multiqcTrimmomatic.sh"

#--------------------------------------------------------------------------
# Pipeline step7: Spades

# /media/sf_Courses/BIT11-Stage/Data/Fastq
