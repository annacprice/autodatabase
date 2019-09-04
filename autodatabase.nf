inFastPath = Channel.fromPath( "/home/ubuntu/data/auto_database/add/*.fasta" )

params.specName = "Mycobacterium"

process taxadd {
    publishDir "/home/ubuntu/data/auto_database/add/edited"

    input:
    file fasta from inFastPath
    
    output:
    "*.fasta"

    """
    taxadd -i "${fasta}" -o "/home/ubuntu/data/auto_database/add/edited" -t "${params.specName}" 
    """
}

