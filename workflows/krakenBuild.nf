// enable dsl2
nextflow.preview.dsl = 2

// import modules
include {autoDatabase_kraken2Build} from '../modules/autoDatabase.nf' params(params)

// define workflow component
// build kraken2 database
workflow krakenBuild {
    take:
      FastaToAdd
    main:
      autoDatabase_kraken2Build(FastaToAdd.collect())
    emit:
      KrakenDatabase = autoDatabase_kraken2Build.out
}
