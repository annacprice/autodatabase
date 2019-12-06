#!/usr/bin/env nextflow

// path to the input fasta files to add to the database
Channel
    .fromPath( "/home/ubuntu/data/auto_database/new/**.fasta" )
    .map { file -> tuple(file.getParent().getName(), file)}
    .set {InFasta}

// add the taxonomic ID to the headers of the fasta files
process TaxAdd {
    publishDir "/home/ubuntu/data/auto_database/add", 
        mode: 'copy',
        saveAs: {filename -> "${filename.split("_")[0]}/$filename"}

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
    publishDir "/home/ubuntu/data/auto_database/add",
	mode: 'copy',
	saveAs: {filename -> "${filename.split("_")[0]}/mash/$filename"}  

    cpus 4

    input:
    file(editfasta) from OutFasta

    output:
    file("*.msh") into MashSketches
   
    script:
    """
    mash sketch "${editfasta}"
    """
}
