process autoDatabase_addTaxon {
    /**
    * Uses species name to find the tax ID and adds it to the contig headers and filename
    * @input tuple val(speciesname), path(fasta)
    * @output path("*.f*")
    * @operator none
    */
   
    publishDir "${params.newDatabase}/${task.process.replaceAll(":", "_")}", pattern: '*.f*', mode: 'copy'

    input:
    tuple val(speciesname), path(fasta)

    output:
    path("*.f*")

    script:
    """
    taxadd -i "${fasta}" -o . -t "${speciesname}"
    """
}

process autoDatabase_mash {
    /**
    * Creates mash distance file for each taxon
    * @input tuple val(taxid), path(fasta)
    * @output path("${taxid}_mashdist.txt")
    * @operator .map{ file -> tuple(file.getName().split("_")[0], file) }.groupTuple(sort: true)
    */
    
    publishDir "${params.newDatabase}/${task.process.replaceAll(":", "_")}", pattern: '*_mashdist.txt', mode: 'copy'

    input:
    tuple val(taxid), path(fasta)

    output:
    path("*_mashdist.txt")

    script:
    """
    mash sketch -o ref *.f*
    mash dist ref.msh ref.msh > ${taxid}_mashdist.txt
    """
}
 
process autoDatabase_qc {
    /**
    * Builds a mash distance matrix for each taxon, which is used to output txt file of high quality assemblies
    * @input path(mashdist)
    * @output path("$taxid_mashdist.txt")
    * @operator .map{ file -> tuple(file.getName().split("_")[0], file) }.groupTuple(sort: true)
    */

    publishDir "${params.newDatabase}/${task.process.replaceAll(":", "_")}", pattern: '*.txt', mode: 'copy'

    input:
    path(mashdist)

    output:
    path("*.txt")

    script:
    """
    fastaselect -i "${mashdist}"
    """
}

process autoDatabase_selectFasta {
    /**
    * Creates a channel containing the high quality assemblies
    * @input tuple val(taxid), path(fasta); tuple val(taxid), path(fasta) 
    * @output path("assemblies/*.f*")
    * @operator .collect().flatten().map{ file -> tuple(file.getName().split("_")[0], file) }.groupTuple(sort: true)
    */

    publishDir "${params.newDatabase}/${task.process.replaceAll(":", "_")}", pattern: 'assemblies/*.f*', mode: 'copy'

    echo true

    input:
    tuple val(taxid), path(fasta)
    tuple val(taxid), path(txt)
    
    output:
    path "assemblies/*.f*" optional true
   
    script:
    """
    ls *.txt | xargs echo
    ls *.f* | xargs echo

    mkdir assemblies

    cat *.txt > clean.txt

    for x in *.f*; do
    if grep -Fxq \$x clean.txt
    then
        mv \$x assemblies/   
    fi
    done    
    """
}

process autoDatabase_kraken2Build {
    /**
    * Builds a kraken2 database using the october 2018 taxonomy
    * @input path(fasta)
    * @output path("*.k2d")
    * @operator .collect()
    */

    publishDir "${params.newDatabase}/${task.process.replaceAll(":", "_")}", pattern: '*.k2d', mode: 'copy'

    cpus 4

    input:
    path(fasta)

    output:
    path("*.k2d")

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
