// build kraken2 database using october 2018 taxonomy
process kraken2_databasebuild {
    publishDir "/home/ubuntu/data/auto_database/database", mode: 'copy'

    cpus 4

    input:
    file(fasta)

    output:
    file("*.k2d")

    script:
    """
    wget ftp://ftp.ncbi.nlm.nih.gov/pub/taxonomy/taxdump_archive/taxdmp_2018-10-01.zip
    unzip taxdmp_2018-10-01.zip
    mkdir taxonomy
    mv names.dmp nodes.dmp taxonomy

    for file in *.fasta; do
       kraken2-build --add-to-library \$file --db .
    done

    kraken2-build --build --threads ${task.cpus} --db .
    """
}

