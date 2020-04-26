# Autodatabase #
Automated build of a kraken2 database using nextflow DSL2. Tested with version 20.01.0

## Quick Start ##
There are four key stages to the workflow:
1) Adding the taxonomic ID to the sequence IDs and the filenames
2) Creating a mash matrix for each taxon
3) Using the mash matrix to select high quality assemblies
4) Building the kraken2 database

The expected input for autodatabase are fasta files. They should sorted into directories for each taxon 
where the directory name is the taxon name with spaces replaced with underscores. E.g.
```
Mycobacterium_avium    Mycobacterium_bovis    Mycobacterium_tuberculosis_complex
```
The workflow will scrape the name of the taxon from the directory name and use it look up the taxonomic ID.

There are three parameters needed to run autodatabase:
* **params.addFasta**
The directory containing the assemblies to be added to the database. Should consist of sub-directories where the fastas
are sorted into named directories for each taxon (see above)
* **params.newDatabase**
The directory where the results of the workflow will be saved. The kraken database .k2d files can be found in ```${params.newDatabase}/krakenBuild_autoDatabase_kraken2Build```
* **params.currentDatabase**
Autodatabase can build on top of the fasta files from a previous database build. The fasta files from a build are found in ```${params.newDatabase}/selectFasta_autoDatabase_selectFasta/assemblies```. 
If there is no previous database build then set to ```null```.
