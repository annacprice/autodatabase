process KrakenAdd {
    publishDir "/home/ubuntu/data/auto_database/database", mode: 'copy'

    input:
    file(fasta)

    output:
    file("library/added/*")

    script:
    """
    for file in *.fasta; do
    kraken2-build --add-to-library \$file --no-masking --db .
    done
    """
}


process KrakenBuildData {
    echo true

    cpus 4    
 
    input:
    file("database")

    output:
    file("database/*.k2d")
 
    script:
    """
    kraken2-build --build --threads ${task.cpus} --db database
    """
}

