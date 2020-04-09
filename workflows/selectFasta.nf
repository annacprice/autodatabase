// enable dsl2
nextflow.preview.dsl = 2

// import modules
include {autoDatabase_mash} from '../modules/autoDatabase.nf' params(params)
include {autoDatabase_qc} from '../modules/autoDatabase.nf' params(params)
include {autoDatabase_selectFasta} from '../modules/autoDatabase.nf' params(params)

// define workflow component
// calculate pairwise distance matrix and use to select high quality assemblies; parallelisation is by taxon
workflow selectFasta {
    take:
      AllFasta
    main:
      autoDatabase_mash(AllFasta)
      autoDatabase_qc(autoDatabase_mash.out)
      autoDatabase_selectFasta(AllFasta, autoDatabase_qc.out.collect().flatten().map{ file -> tuple(file.getName().split("_")[0], file) }.groupTuple(sort: true))
    emit:
      FastaToAdd = autoDatabase_selectFasta.out
}
