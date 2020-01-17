process KrakenAdd {

    input:
    file(fasta)

    output:
    path("library/added/*.fna")

    script:
    """
    kraken2-build --add-to-library ${fasta} --no-masking --db .
    """
}
