process FastaAdd {
    echo true

    cpus 1

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

