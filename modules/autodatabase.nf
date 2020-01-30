// add taxon ID to fasta conitgs and file name
process autodatabase_addtaxon {
   
    input:
    tuple(val(name), file(fasta))

    output:
    file("*.fasta")

    script:
    """
    taxadd -i "${fasta}" -o . -t "${name}"
    """
}

// create mash output txt file for each taxon with pairwise distances
process autodatabase_mashdist {

    input:
    file(mash)

    output:
    file("*_mashdist.txt")

    script:
    """
    ls *.msh | cut -d _ -f 1 | sort | uniq > taxid.txt

    while read x
    do
    for i in \$x*.msh
     do
      for j in \$x*.msh
       do
        mash dist \$i \$j
       done
     done > "\$x"_mashdist.txt
    done < taxid.txt
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

    input:
    file(fasta)
    file(txt)

    output:
    path "add*.fasta" optional true

    script:
    """
    ls *.txt | xargs echo
    cat *.txt > clean.txt
    for x in *.fasta; do
    if grep -Fxq \$x clean.txt
    then
        echo \$x
        mv \$x add\$x
    fi
    done    
    """
}  
