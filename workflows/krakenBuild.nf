// enable dsl2
nextflow.preview.dsl = 2

// import modules
include {autoDatabase_kraken2Build} from '../modules/autoDatabase.nf' params(params)
include {autoDatabase_krona} from '../modules/autoDatabase.nf' params(params)

// define workflow component
// build kraken2 database
workflow krakenBuild {
    take:
      FastaToAdd
    main:
      autoDatabase_kraken2Build(FastaToAdd.collect())
      autoDatabase_krona(autoDatabase_kraken2Build.out.database_txt)
    emit:
      KrakenDatabase = autoDatabase_kraken2Build.out.kraken2_database
      KronaChart = autoDatabase_kraken2Build.out.database_txt
}
