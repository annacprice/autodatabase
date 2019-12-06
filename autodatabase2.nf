#!/usr/bin/env nextflow

// path to the mash sketch files
Channel
    .fromPath( "/home/ubuntu/data/auto_database/add/*/mash/*.msh")
    .set {MashSketches}

// calculate the mash distances
process MashDist {
    publishDir "/home/ubuntu/data/auto_database/add", 
	mode: 'copy',
        saveAs: {filename -> "${filename.split("_")[0]}/mash/$filename"}
    
    cpus 1

    input:
    file(mash) from MashSketches.collect()

    output:
    file("*_mashdist.txt") into MashDistances

 
    script:
    """
    mashpair
    """
}

// build the mash matrix and use to sort fastas into clean and discard groups
process MashSort {
    publishDir "/home/ubuntu/data/auto_database/add/", 
        mode: 'copy',
        saveAs: {filename -> "${filename.split("-")[0]}/$filename"}

    cpus 2

    input:
    file(mashdist) from MashDistances.flatten()
 
    output:
    file("*.txt") into FastaMove

    script:
    """
    fastaselect -i "${mashdist}"
    """
}

