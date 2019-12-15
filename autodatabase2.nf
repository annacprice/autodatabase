#!/usr/bin/env nextflow

// path to the mash sketch files
Channel
    .fromPath( "/home/ubuntu/data/auto_database/add/*/mash/*.msh")
    .set {MashSketches}

// path to the fasta files
Channel
    .fromPath( "/home/ubuntu/data/auto_database/add/*/*.fasta" )
    .map {file -> 
        def tax = file.getParent().getName().split("_")[0]
        return tuple(tax, file)
     }
    .groupTuple()
    .set {FastaTax}

Channel
    .fromPath( "/home/ubuntu/data/auto_database/add/*/*.fasta" )
    .set {JustFasta}

Channel
    .watchPath( "/home/ubuntu/data/auto_database/add/*/*.fasta", 'modify' )
    .set {FastaChange}

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

// build the mash matrix and use to sort fastas
process MashSort {
    publishDir "/home/ubuntu/data/auto_database/add", 
        mode: 'copy',
        saveAs: {filename -> "${filename.split("_")[0]}/$filename"}

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

// mark poor quality fastas
process FastaDiscard {
    echo true

    publishDir "/home/ubuntu/data/auto_database/add",
        mode: 'copy',
        overwrite: 'true',
        saveAs: {filename -> "${filename.split("_")[0]}/$filename"}

    cpus 4

    input:
    file(fasta) from JustFasta
    file("*.txt") from FastaMove.collect()

    output:
    file("*.fasta") optional true into DiscardFasta

    script:
    """
    cat *.txt > discard.txt
    if grep -Fxq "${fasta}" discard.txt
    then
        touch "${fasta}"
    fi
    """
}

discard_dir = file("/home/ubuntu/data/auto_database/discard")
FastaChange.flatMap().subscribe { it.moveTo(discard_dir) }
