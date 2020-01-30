// create mash sketches
process mash_sketch {
   
    input:
    file(fasta)

    output:
    file("*.msh")

    script:
    """
    mash sketch "${fasta}"
    """
}
    
