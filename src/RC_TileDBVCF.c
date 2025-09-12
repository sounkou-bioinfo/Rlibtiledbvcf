/**
 * @file Rlibtiledbvcf.c
 * @brief R bindings for TileDB-VCF - Main implementation
 */

#include "RC_TileDBVCF.h"

/* ********************************* */
/*          ERROR HANDLING          */
/* ********************************* */

SEXP _rtiledbvcf_handle_reader_error(tiledb_vcf_reader_t* reader, const char* function_name) {
    const char* err_msg = "Unknown reader error";
    tiledb_vcf_error_t* vcf_error = NULL;
    
    if (reader != NULL) {
        if (tiledb_vcf_reader_get_last_error(reader, &vcf_error) == TILEDB_VCF_OK && vcf_error != NULL) {
            tiledb_vcf_error_get_message(vcf_error, &err_msg);
        }
    }
    
    Rf_error("Rlibtiledbvcf reader error in %s: %s", function_name, err_msg);
    return R_NilValue; /* Never reached, but keeps compiler happy */
}

SEXP _rtiledbvcf_handle_writer_error(tiledb_vcf_writer_t* writer, const char* function_name) {
    const char* err_msg = "Unknown writer error";
    tiledb_vcf_error_t* vcf_error = NULL;
    
    if (writer != NULL) {
        if (tiledb_vcf_writer_get_last_error(writer, &vcf_error) == TILEDB_VCF_OK && vcf_error != NULL) {
            tiledb_vcf_error_get_message(vcf_error, &err_msg);
        }
    }
    
    Rf_error("Rlibtiledbvcf writer error in %s: %s", function_name, err_msg);
    return R_NilValue; /* Never reached, but keeps compiler happy */
}

SEXP _rtiledbvcf_handle_general_error(const char* function_name, const char* custom_message) {
    Rf_error("Rlibtiledbvcf error in %s: %s", function_name, custom_message);
    return R_NilValue; /* Never reached, but keeps compiler happy */
}

/* ********************************* */
/*          VERSION FUNCTIONS       */
/* ********************************* */

SEXP RC_tiledb_vcf_version(void) {
    const char* version = NULL;
    SEXP result;
    
    /* Get version from TileDB-VCF */
    tiledb_vcf_version(&version);
    
    if (version == NULL) {
        version = "unknown";
    }
    
    /* Create R character vector */
    PROTECT(result = Rf_allocVector(STRSXP, 1));
    SET_STRING_ELT(result, 0, Rf_mkChar(version));
    
    UNPROTECT(1);
    return result;
}

/* ********************************* */
/*        UTILITY FUNCTIONS         */
/* ********************************* */

SEXP RC_tiledb_vcf_available(void) {
    SEXP result;
    
    /* Create R logical vector */
    PROTECT(result = Rf_allocVector(LGLSXP, 1));
    
    /* TileDB-VCF is available if we can call the version function */
    const char* version = NULL;
    tiledb_vcf_version(&version);
    
    LOGICAL(result)[0] = (version != NULL) ? TRUE : FALSE;
    
    UNPROTECT(1);
    return result;
}
