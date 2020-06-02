process autoDatabase_addTaxon {
    /**
    * Uses species name to find the tax ID and adds it to the contig headers and filename
    * @input tuple val(speciesname), path(fasta)
    * @output path("*.f*")
    * @operator none
    */
   
    //publishDir "${params.newDatabase}/${task.process.replaceAll(":", "_")}", pattern: '*.f*', mode: 'copy'

    container "${params.simgdir}/autoDatabase_pythonenv.simg"

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
    * @output tuple val(taxid), path("${taxid}_mashdist.txt")
    * @operator .map{ file -> tuple(file.getName().split("_")[0], file) }.groupTuple(sort: true)
    */
    
    publishDir "${params.newDatabase}/${task.process.replaceAll(":", "_")}", pattern: '*_mashdist.txt', mode: 'copy'

    container "${params.simgdir}/autoDatabase_mash.simg"

    input:
    tuple val(taxid), path(taxfiles)

    output:
    tuple val(taxid), path("${taxid}_mashdist.txt")

    script:
    """
    mash sketch -o ref *.f*
    mash dist ref.msh ref.msh > ${taxid}_mashdist.txt
    """
}
 
process autoDatabase_qc {
    /**
    * Builds a mash distance matrix for each taxon, which is used to output txt file of high quality assemblies
    * @input tuple val(taxid), path(mashdist)
    * @output tuple val(taxid), path("*.txt")
    * @operator .map{ file -> tuple(file.getName().split("_")[0], file) }.groupTuple(sort: true)
    */

    publishDir "${params.newDatabase}/${task.process.replaceAll(":", "_")}", pattern: '*.txt', mode: 'copy'

    container "${params.simgdir}/autoDatabase_pythonenv.simg"

    input:
    tuple val(taxid), path(mashdist)

    output:
    tuple val(taxid), path("*.txt")

    script:
    """
    fastaselect -i "${mashdist}"
    """
}

process autoDatabase_cleanFasta {
    /**
    * Creates a channel containing the high quality assemblies
    * @input tuple val(taxid), path(fasta) path(txt)
    * @output path("assemblies/*.f*")
    * @operator .map{ file -> tuple(file.getName().split("_")[0], file) }.groupTuple(sort: true).join(AllFasta, by: 0)
    */

    publishDir "${params.newDatabase}/${task.process.replaceAll(":", "_")}", pattern: 'assemblies/*.f*', mode: 'copy'

    echo true

    input:
    tuple val(taxid), path(txt), path(fasta)
    
    output:
    path "assemblies/*.f*" optional true
   
    script:
    """
    mkdir assemblies

    for x in *.f*; do
    if grep -Fxq \$x ${taxid}_clean.txt
    then
        mv \$x assemblies/   
    fi
    done    
    """
}

process autoDatabase_kraken2Build {
    /**
    * Builds a kraken2 database using the may 2020 taxonomy
    * @input path(fasta)
    * @output path("*.k2d")
    * @operator .collect()
    */

    publishDir "${params.newDatabase}/${task.process.replaceAll(":", "_")}", pattern: '*.k2d', mode: 'copy'

    container "${params.simgdir}/autoDatabase_kraken2.simg"

    cpus 24

    input:
    path(fasta)

    output:
    path("*.k2d")

    script:
    """
    wget ftp://ftp.ncbi.nlm.nih.gov/pub/taxonomy/taxdump_archive/taxdmp_2020-05-01.zip
    unzip taxdmp_2020-05-01.zip

    largestTax=`sort -t't' -k1nr names.dmp | head -1 | cut -f1`
    tomidaeTax=\$((largestTax+1))
    echo -e "\$tomidaeTax\t|\tMycobacterium tomidae\t|\t\t|\tscientific name\t|" >> names.dmp
    echo -e "\$tomidaeTax\t|\t120793\t|\tspecies\t|\t\t|\t11\t|\t1\t|\t1\t|\t1\t|\t1\t|\t1\t|\t1\t|\t1\t|" >> nodes.dmp

    mkdir taxonomy
    mv names.dmp nodes.dmp taxonomy

    for file in **.f*; do
       kraken2-build --add-to-library \$file --db .
    done

    kraken2-build --build --threads ${task.cpus} --db .
    """
}
