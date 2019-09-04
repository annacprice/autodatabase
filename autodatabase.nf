inFastPath = Channel.fromPath( "/home/ubuntu/data/auto_database/add/*.fasta" )

params.specName = "Mycobacterium"

process TaxAdd {
    publishDir "/home/ubuntu/data/auto_database/add/edited"

    input:
    file(fasta) from inFastPath
    
    output:
    file("*.fasta") into MashDist

    """
    taxadd -i "${fasta}" -o . -t "${params.specName}" 
    """
}

