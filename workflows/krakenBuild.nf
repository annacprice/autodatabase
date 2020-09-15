// enable dsl2
nextflow.preview.dsl = 2

// import modules
include {autoDatabase_kraken2Build} from '../modules/autoDatabase.nf' params(params)
include {autoDatabase_krona} from '../modules/autoDatabase.nf' params(params)

// define workflow component
// build kraken2 database and produce krona chart showing composition of the database
workflow krakenBuild {
    take:
      FastaToAdd
      TaxonomyNames
      TaxonomyNodes
    main:
      autoDatabase_kraken2Build(FastaToAdd.collect(), TaxonomyNames, TaxonomyNodes)
      autoDatabase_krona(autoDatabase_kraken2Build.out.database_txt)
    emit:
      KrakenDatabase = autoDatabase_kraken2Build.out.kraken2_database
      KrakenTxt = autoDatabase_kraken2Build.out.database_txt
      KronaReport = autoDatabase_krona.out.database_html
}
