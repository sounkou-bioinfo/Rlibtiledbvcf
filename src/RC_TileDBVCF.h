/**
 * @file Rlibtiledbvcf.h
 * @brief R bindings for TileDB-VCF
 * 
 * This file declares the R API functions for TileDB-VCF operations.
 * All R-callable functions are prefixed with RC_ and return SEXP objects.
 */

#ifndef RTILEDBVCF_H
#define RTILEDBVCF_H

#include <R.h>
#include <Rinternals.h>
#include <R_ext/Rdynload.h>

/* TileDB-VCF C API headers */
#include "tiledbvcf/tiledbvcf.h"
#include "tiledbvcf/tiledbvcf_enum.h"


/* ********************************* */
/*          VERSION FUNCTIONS       */
/* ********************************* */

/**
 * @brief Get TileDB-VCF version
 * @return R character vector with version string
 */
SEXP RC_tiledb_vcf_version(void);

/* ********************************* */
/*        UTILITY FUNCTIONS         */
/* ********************************* */

/**
 * @brief Check if TileDB-VCF library is available
 * @return R logical vector (TRUE if available)
 */
SEXP RC_tiledb_vcf_available(void);

/* ********************************* */
/*          ERROR HANDLING          */
/* ********************************* */

/**
 * @brief Internal function to handle TileDB-VCF errors from reader
 * @param reader TileDB-VCF reader (if available)
 * @param function_name Name of the function where error occurred
 * @return Always returns R_NilValue, but throws R error
 */
SEXP _rtiledbvcf_handle_reader_error(tiledb_vcf_reader_t* reader, const char* function_name);

/**
 * @brief Internal function to handle TileDB-VCF errors from writer
 * @param writer TileDB-VCF writer (if available)
 * @param function_name Name of the function where error occurred
 * @return Always returns R_NilValue, but throws R error
 */
SEXP _rtiledbvcf_handle_writer_error(tiledb_vcf_writer_t* writer, const char* function_name);

/**
 * @brief Internal function to handle general TileDB-VCF errors
 * @param function_name Name of the function where error occurred
 * @param custom_message Custom error message
 * @return Always returns R_NilValue, but throws R error
 */
SEXP _rtiledbvcf_handle_general_error(const char* function_name, const char* custom_message);

/* ********************************* */
/*         HELPER MACROS            */
/* ********************************* */

/**
 * @brief Macro to check TileDB-VCF return codes and handle reader errors
 */
#define RTILEDBVCF_CHECK_READER_ERROR(reader, rc, func) \
    do { \
        if ((rc) != TILEDB_VCF_OK) { \
            return _rtiledbvcf_handle_reader_error((reader), (func)); \
        } \
    } while(0)

/**
 * @brief Macro to check TileDB-VCF return codes and handle writer errors
 */
#define RTILEDBVCF_CHECK_WRITER_ERROR(writer, rc, func) \
    do { \
        if ((rc) != TILEDB_VCF_OK) { \
            return _rtiledbvcf_handle_writer_error((writer), (func)); \
        } \
    } while(0)

/**
 * @brief Macro to check for null pointers and throw R error
 */
#define RTILEDBVCF_CHECK_NULL(ptr, message) \
    do { \
        if ((ptr) == NULL) { \
            Rf_error("Rlibtiledbvcf: %s", (message)); \
        } \
    } while(0)



#endif /* RTILEDBVCF_H */
