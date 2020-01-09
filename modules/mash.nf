process MashSketch {
    publishDir "/home/ubuntu/data/auto_database/add",
        mode: 'copy',
        saveAs: {filename -> "${filename.split("_")[0]}/mash/$filename"}

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
