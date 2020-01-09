process TaxAdd {
    publishDir "/home/ubuntu/auto_database/add",
        mode: 'copy',
        saveAs: {filename -> "${filename.split("_")[0]}/$filename"}


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
