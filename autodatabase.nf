#!/usr/bin/env nextflow

// path to the input fasta files to add to the database
inFastPath = Channel.fromPath( "/home/ubuntu/data/auto_database/add/*.fasta" )

// define parameter for the species name
params.specName = "Mycobacterium"

// add the taxonomic ID to the headers of the fasta files
process TaxAdd {
    publishDir "/home/ubuntu/data/auto_database/add/edited", mode: 'copy'

    cpus 4

    input:
    file(fasta) from inFastPath
   
    output:
    file("*.fasta") into OutFasta

    script:
    """
    taxadd -i "${fasta}" -o . -t "${params.specName}" 
    """
}

// create the mash sketch files
process MashSketch {
    publishDir "/home/ubuntu/data/auto_database/add/edited", mode: 'copy'    

    cpus 4

    input:
    file(editfasta) from OutFasta

    output:
    file("*.msh") into MashSketches
   
    script:
    """
    mash sketch -o reference_${editfasta} "${editfasta}"
    """
}

// calculate the mash distances
process MashDist {
    publishDir "/home/ubuntu/data/auto_database/add/edited", mode: 'copy'
    
    cpus 1

    input:
    file("*.msh") from MashSketches.collect()

    output:
    file("*.txt") into MashDistances
 
    script:
    """
    mashpair
    """
}

