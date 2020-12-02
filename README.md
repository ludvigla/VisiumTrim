# VisiumTrim
TSO and polyA trimming of fastq files generated with 10x Visium


## Installation
Install cutadapt:

`pip install cutadapt`

Make sure that the script is executable:
`chmod +x TSO_polyA_trimming.sh`


## Usage

Trim a fastq file with default settings:

`TSO_polyA_trimming.sh R2_fastq.gz`


Adjust minimal polyA homopolymer length (default 10):

`TSO_polyA_trimming.sh R2_fastq.gz -l 15`


Adjust error tolerance for adapter search (default 0.1):

`TSO_polyA_trimming.sh R2_fastq.gz -e 0`


Adjust overlap (minimal length of partial match, default 5):

`TSO_polyA_trimming.sh R2_fastq.gz --overlap 10`


Change output path:

`TSO_polyA_trimming.sh R2_fastq.gz -o trimmed_R2.fastq.gz`
