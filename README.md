# autodatabase #
Automated build of a Kraken2 database using Nextflow DSL2. Requires Nextflow version>= 20.01.0 and either Docker or Singularity.

## Quick Start ##
There are seven stages to the workflow:
1) Downloading the NCBI taxonomy (autoDatabase_getTaxonomy)
2) Adding the taxonomic ID to the sequence IDs and the filenames (autoDatabase_addTaxon)
3) Creating a mash matrix for each taxon (autoDatabase_mash)
4) Using the mash matrix to select high quality assemblies (autoDatabase_qc)
5) Creating a channel containing the high quality assemblies (autoDatabase_cleanFasta)
6) Building the Kraken2 database (autoDatabase_kraken2Build)
7) Creating a Krona chart showing the composition of the Kraken2 database (autoDatabase_krona) 

The expected input for autodatabase are fasta files. They should sorted into directories for each taxon 
where the directory name is the taxon name with spaces replaced with underscores. E.g.
```
Mycobacterium_avium    Mycobacterium_bovis    Mycobacterium_tuberculosis_complex
```
The workflow will scrape the name of the taxon from the directory name and use it look up the taxonomic ID.

There are five global parameters needed to run autodatabase which can be set in `nextflow.config`:
* **params.addFasta**
The directory containing the assemblies to be added to the database. Should consist of sub-directories where the fastas
are sorted into named directories for each taxon (see above)
* **params.newDatabase**
The directory where the results of the workflow will be saved. The default is `${baseDir}/results`. On completion of the pipeline, the output kraken database .k2d files can be found in `${params.newDatabase}/krakenBuild_autoDatabase_kraken2Build`
* **params.previousDatabase**
Autodatabase can build on top of the fasta files from a previous database build. The fasta files from a completed build are found in `${params.newDatabase}/selectFasta_autoDatabase_cleanFasta/assemblies` 
If there is no previous database build then set to `null`
* **params.ncbiDate**
Date stamp of the NCBI taxonomy you wish to use to build the database. Takes the form YYYY-MM-DD
* **params.modeRange**
For each taxon, autodatabase builds a mash distance matrix, finds the average mash distance for each assembly, and then finds the mode of the average mash distances to 2 s.f. The assemblies that have an average distance that is within `params.modeRange` of the mode will be used to build the database. Default value is 0.1, i.e. accepts mash distances within the range: mode&pm;10%

The pipeline requires either Docker or Singularity to run. Scripts for building the containers needed to run the pipeline can be found in `docker` and `singularity`.

To run the pipeline:
```
nextflow run main.nf -profile [docker, singularity]
```

The workflow for the pipeline can be found below, for more information consult the [wiki](https://github.com/annacprice/autodatabase/wiki)

## Workflow ##
<img height="600" src="https://github.com/annacprice/autodatabase/blob/master/workflow.png" />
