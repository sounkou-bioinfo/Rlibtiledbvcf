/**
 * @file Rlibtiledbvcf_init.c
 * @brief R package initialization and registration
 */

#include "RC_TileDBVCF.h"

/* ********************************* */
/*        REGISTRATION TABLE        */
/* ********************************* */

/**
 * @brief Table of R-callable functions
 * 
 * This table registers all the functions that can be called from R.
 * Each entry contains:
 * - Function name (as seen from R)
 * - C function pointer  
 * - Number of arguments
 */
static const R_CallMethodDef CallEntries[] = {
    /* Version and utility functions */
    {"RC_tiledb_vcf_version",    (DL_FUNC) &RC_tiledb_vcf_version,    0},
    {"RC_tiledb_vcf_available",  (DL_FUNC) &RC_tiledb_vcf_available,  0},
    
    /* Sentinel - must be last */
    {NULL, NULL, 0}
};

/* ********************************* */
/*      PACKAGE INITIALIZATION     */
/* ********************************* */

/**
 * @brief Package initialization function
 * 
 * This function is called when the package is loaded via library() or require().
 * It registers all the C functions that can be called from R.
 * 
 * @param dll Dynamic library information
 */
void R_init_Rlibtiledbvcf(DllInfo *dll) {
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
    R_forceSymbols(dll, TRUE);
}
