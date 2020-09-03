# autodatabase #
Automated build of a Kraken2 database using Nextflow DSL2. Requires Nextflow version>= 20.01.0 and either Docker or Singularity.

## Quick Start ##
There are four key stages to the workflow:
1) Adding the taxonomic ID to the sequence IDs and the filenames
2) Creating a mash matrix for each taxon
3) Using the mash matrix to select high quality assemblies
4) Building the Kraken2 database

The expected input for autodatabase are fasta files. They should sorted into directories for each taxon 
where the directory name is the taxon name with spaces replaced with underscores. E.g.
```
Mycobacterium_avium    Mycobacterium_bovis    Mycobacterium_tuberculosis_complex
```
The workflow will scrape the name of the taxon from the directory name and use it look up the taxonomic ID.

There are three global parameters needed to run autodatabase which can be set in `nextflow.config`:
* **params.addFasta**
The directory containing the assemblies to be added to the database. Should consist of sub-directories where the fastas
are sorted into named directories for each taxon (see above)
* **params.newDatabase**
The directory where the results of the workflow will be saved. The default is `${baseDir}/results`. The output kraken database .k2d files can be found in `${params.newDatabase}/krakenBuild_autoDatabase_kraken2Build`
* **params.currentDatabase**
Autodatabase can build on top of the fasta files from a previous database build. The fasta files from a completed build are found in `${params.newDatabase}/selectFasta_autoDatabase_cleanFasta/assemblies` 
If there is no previous database build then set to `null`

The pipeline requires either Docker or Singularity to run. Scripts for building the containers needed to run the pipeline can be found in `docker` and `singularity`.

To run the pipeline:
```
nextflow run main.nf -profile [docker, singularity]
```
