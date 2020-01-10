process MashSketch {

    cpus 4

    input:
    file(fasta)

    output:
    file("*.msh")

    script:
    """
    mash sketch "${fasta}"
    """
}

process MashDist {
 
    cpus 1

    input:
    file(mash)

    output:
    file("*_mashdist.txt")

    script:
    """
    mashpair
    """
}

process MashSort {

    cpus 2

    input:
    file(mashdist)

    output:
    file("*.txt")

    script:
    """
    fastaselect -i "${mashdist}"
    """
} 
   
