// add taxon ID to fasta conitgs and file name
process autodatabase_addtaxon {
   
    input:
    tuple(val(name), file(fasta))

    output:
    file("*.f*")

    script:
    """
    taxadd -i "${fasta}" -o . -t "${name}"
    """
}

// create mash distance matrix per taxon
process autodatabase_mash {
    
    input:
    tuple(val(tax), file(fasta))

    output:
    file("*_mashdist.txt")

    script:
    """
    mash sketch -o ref *.f*
    mash dist ref.msh ref.msh > ${tax}_mashdist.txt
    """
}


// build distance matrix and output txt file with list of high quality assemblies 
process autodatabase_qc {

    input:
    file(mashdist)

    output:
    file("*.txt")

    script:
    """
    fastaselect -i "${mashdist}"
    """
}

// create channel for the high quality assemblies
process autodatabase_selectfasta {

    echo true

    input:
    tuple(val(tax), file(fasta))
    tuple(val(tax), file(txt))
    
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

// build kraken2 database using october 2018 taxonomy
process kraken2_databasebuild {

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
