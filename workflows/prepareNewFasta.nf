// enable dsl2
nextflow.preview.dsl = 2

// import modules
include {autoDatabase_addTaxon} from '../modules/autoDatabase.nf' params(params)
include {autoDatabase_getTaxonomy} from '../modules/autoDatabase.nf' params(params)

// define workflow component
// add taxon to header and filename and for new assemblies
workflow prepareNewFasta {
    take:
      EditFasta
    main:
      autoDatabase_getTaxonomy()
      autoDatabase_addTaxon(EditFasta.combine(autoDatabase_getTaxonomy.out.ncbi_names))
    emit:
      TaxonomyNames = autoDatabase_getTaxonomy.out.ncbi_names
      TaxonomyNodes = autoDatabase_getTaxonomy.out.ncbi_nodes
      NewFasta = autoDatabase_addTaxon.out
}
