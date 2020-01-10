process TaxAdd {
   
    cpus 4

    input:
    set val(name), file(fasta)

    output:
    file("*.fasta")

    script:
    """
    taxadd -i "${fasta}" -o . -t "${name}"
    """
}

