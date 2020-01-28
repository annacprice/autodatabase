process MashSketch {
   
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

process MashDist {
    echo true

    cpus 1

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

process MashSort {

    cpus 2

    input:
    file(mashdist)

    output:
    file("*.txt")

    script:
    """
    fastaselect -i "${mashdist}"
    """
}    
