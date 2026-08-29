#!/bin/bash 
# This script downloads ALL chromosome sequences for the genome assembly GCA_902167145
# If any sequences are from a WGS contig set, the script will downloads the full set file from ENA public FTP server & extract the relevant sequences from it.
# All downloaded chromosome sequences are gathered together in the file GCA_902167145-chromosomes.fasta when the script completes.

# If any sequences could not be extracted, their IDs will be gathered in GCA_902167145-chromosomes.fasta_not-found.txt when the script completes.

# NOTE: If the output file GCA_902167145-chromosomes.fasta already exists in current working directory, please move or delete it as otherwise this script will fail.
# NOTE: The script might need permission to be executed in your terminal. To grant execute" permission, please run the following command: chmod +x GCA_902167145-chromosomes-fasta.sh 
set -e 
if [ -f "GCA_902167145-chromosomes.fasta" ]; then
echo "ERROR :  "GCA_902167145-chromosomes.fasta" already exists here. Please delete to proceed. Exiting"
exit 1
fi 
wget https://www.ebi.ac.uk/ena/browser/api/fasta/LR618874.1 -O - >> GCA_902167145-chromosomes.fasta 
wget https://www.ebi.ac.uk/ena/browser/api/fasta/LR618875.1 -O - >> GCA_902167145-chromosomes.fasta 
wget https://www.ebi.ac.uk/ena/browser/api/fasta/LR618876.1 -O - >> GCA_902167145-chromosomes.fasta 
wget https://www.ebi.ac.uk/ena/browser/api/fasta/LR618877.1 -O - >> GCA_902167145-chromosomes.fasta 
wget https://www.ebi.ac.uk/ena/browser/api/fasta/LR618878.1 -O - >> GCA_902167145-chromosomes.fasta 
wget https://www.ebi.ac.uk/ena/browser/api/fasta/LR618879.1 -O - >> GCA_902167145-chromosomes.fasta 
wget https://www.ebi.ac.uk/ena/browser/api/fasta/LR618880.1 -O - >> GCA_902167145-chromosomes.fasta 
wget https://www.ebi.ac.uk/ena/browser/api/fasta/LR618881.1 -O - >> GCA_902167145-chromosomes.fasta 
wget https://www.ebi.ac.uk/ena/browser/api/fasta/LR618882.1 -O - >> GCA_902167145-chromosomes.fasta 
wget https://www.ebi.ac.uk/ena/browser/api/fasta/LR618883.1 -O - >> GCA_902167145-chromosomes.fasta 