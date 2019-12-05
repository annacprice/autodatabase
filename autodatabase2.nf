#!/usr/bin/env nextflow

// path to the mash sketch files
Channel
    .fromPath( "/home/ubuntu/data/auto_database/add/*/mash/*.msh")
    .set {MashSketches}

// calculate the mash distances
process MashDist {
    publishDir "/home/ubuntu/data/auto_database/add", 
	mode: 'copy'
    
    cpus 1

    input:
    file(mash) from MashSketches.collect()

    output:
    file("*.txt") into MashDistances

 
    script:
    """
    mashpair
    """
}

