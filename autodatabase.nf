#!/usr/bin/env nextflow

// path to the input fasta files to add to the database
InFasta = Channel
.fromPath( "/home/ubuntu/data/auto_database/add/**.fasta" )
.map { file -> tuple(file.getParent().getName(), file)}

// add the taxonomic ID to the headers of the fasta files
process TaxAdd {
    publishDir "/home/ubuntu/data/auto_database/edit", mode: 'copy'

    cpus 4

    input:
    set val(name), file(fasta) from InFasta
     
    output:
    file("*.fasta") into OutFasta

    script:
    """
    taxadd -i "${fasta}" -o . -t "${name}"
    """
}

// create the mash sketch files
process MashSketch {
    publishDir "/home/ubuntu/data/auto_database/edit", mode: 'copy'    

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
    publishDir "/home/ubuntu/data/auto_database/edit", mode: 'copy'
    
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

// build the mash matrix and use to sort fastas into clean and discard groups
process MashSort {
    publishDir "/home/ubuntu/data/auto_database/add/edited", mode: 'copy'

    cpus 1

    input:
    file(mashdist) from MashDistances
 
    output:
    file("*.txt") into FastaMove

    script:
    """
    fastaselect -i "${mashdist}"
    """
}
