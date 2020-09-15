process autoDatabase_getTaxonomy {
    /**
    * Download the NCBI taxonomy, identified using params.ncbiDate
    * @input none
    * @output tuple path("names.dmp"), path("nodes.dmp")
    * @operator none
    */

    output:
    path("names.dmp", emit: ncbi_names)
    path("nodes.dmp", emit: ncbi_nodes)

    script:
    """
    wget ftp://ftp.ncbi.nlm.nih.gov/pub/taxonomy/taxdump_archive/taxdmp_${params.ncbiDate}.zip
    unzip taxdmp_${params.ncbiDate}.zip
    largestTax=`sort -t't' -k1nr names.dmp | head -1 | cut -f1`
    tomidaeTax=\$((largestTax+1))
    echo -e "\$tomidaeTax\t|\tMycobacterium tomidae\t|\t\t|\tscientific name\t|" >> names.dmp
    echo -e "\$tomidaeTax\t|\t120793\t|\tspecies\t|\t\t|\t11\t|\t1\t|\t1\t|\t1\t|\t1\t|\t1\t|\t1\t|\t1\t|" >> nodes.dmp
    """
}

process autoDatabase_addTaxon {
    /**
    * Uses species name to find the tax ID and adds it to the contig headers and filename
    * @input tuple val(speciesname), path(fasta)
    * @output path("*.f*")
    * @operator none
    */
   
    //publishDir "${params.newDatabase}/${task.process.replaceAll(":", "_")}", pattern: '*.f*', mode: 'copy'

    input:
    tuple val(speciesname), path(fasta), path(names)

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
    * @output path("*.k2d") path("database.txt")
    * @operator .collect()
    */

    publishDir "${params.newDatabase}/${task.process.replaceAll(":", "_")}", pattern: '*.k2d', mode: 'copy'
    publishDir "${params.newDatabase}/${task.process.replaceAll(":", "_")}", pattern: 'database.txt', mode: 'copy'

    cpus 24

    input:
    path(fasta)
    path(names)
    path(nodes)

    output:
    path("*.k2d", emit: kraken2_database)
    path("database.txt", emit: database_txt)

    script:
    """
    mkdir taxonomy
    mv names.dmp nodes.dmp taxonomy

    for file in **.f*; do
        kraken2-build --add-to-library \$file --db .
    done

    kraken2-build --build --threads ${task.cpus} --db .
    kraken2-inspect --db . > database.txt
    """
}

process autoDatabase_krona {
    /**
    * Creates a krona chart showing the composition of the built kraken2 database
    * @input path(databasetxt)
    * @output path("database.html")
    * @operator none
    */

    publishDir "${params.newDatabase}/${task.process.replaceAll(":", "_")}", pattern: 'database.html', mode: 'copy'

    input:
    path(databasetxt)
    
    output:
    path("database.html", emit: database_html)

    script:
    """
    ktImportTaxonomy -m 3 -t 5 "${databasetxt}" -o database.html
    """
}
