# For accessing python file
cdef extern from "Python.h":
    FILE* PyFile_AsFile(object)
    void  fprintf(FILE* f, char* s, char* s)
cdef extern from "fileobject.h":
    ctypedef class __builtin__.file [object PyFileObject]:
        pass

cdef extern from "unistd.h":
    ctypedef unsigned off_t

cdef extern from "inttypes.h":
    ctypedef int int64_t
    ctypedef unsigned short uint16_t

cdef extern from "stdio.h":
    ctypedef struct FILE:
        pass

cdef extern from "easel.h":
    ctypedef int ESL_DSQ

cdef extern from "esl_sq.h":
    ctypedef struct ESL_SQ:
        char *name
        char *acc
        char *desc
        char *seq
        ESL_DSQ *dsq
        char *ss
        int64_t n # Length of sequence and ss
        int64_t L # Source sequence length
        int64_t idx

        # Offsets
        off_t doff
        off_t roff

    ESL_SQ *esl_sq_Create()
    ESL_SQ *esl_sq_CreateFrom(char *name, char *seq, char *desc,
            char *acc, char *ss)
    int esl_sq_Reuse(ESL_SQ *sq)
    void esl_sq_Destroy(ESL_SQ *sq)

    # Manipulations
    int esl_sq_ReverseComplement(ESL_SQ *sq)
    int esl_sq_Copy(ESL_SQ *src, ESL_SQ *dst)

    # Setters
    int esl_sq_SetName(ESL_SQ *sq,  char *name)
    int esl_sq_SetAccession(ESL_SQ *sq,  char *acc)
    int esl_sq_SetDesc(ESL_SQ *sq,  char *desc)
    int esl_sq_SetSource(ESL_SQ *sq,  char *source)

cdef extern from "esl_sqio.h":
    ctypedef struct ESL_SQASCII_DATA:
        ESL_SSI *ssi
    ctypedef union ESL_SQDATA:
        ESL_SQASCII_DATA ascii

    ctypedef struct ESL_SQFILE:
        char *filename
        int format
        ESL_SQDATA data

    int esl_sqfile_Open(char *seqfile, int fmt, char *env, ESL_SQFILE **ret_sqfp)
    int esl_sqfile_OpenSSI(ESL_SQFILE *sqfp, char *ssifile_hint)
    int esl_sqfile_PositionByKey(ESL_SQFILE *sqfp, char *key)
    void esl_sqfile_Close(ESL_SQFILE *sqfp)

    int esl_sqio_Read(ESL_SQFILE *sqfp, ESL_SQ *sq)
    int esl_sqio_ReadInfo(ESL_SQFILE *sqfp, ESL_SQ *sq)
    int esl_sqio_Write(FILE *fp, ESL_SQ *s, int format, int update)

cdef extern from "esl_ssi.h":
    ctypedef struct ESL_SSI:
        pass

    ctypedef struct ESL_NEWSSI:
        char *ssifile
        FILE *ssifp

    # Creating
    int esl_newssi_Open(char *ssifile, int allow_overwrite, ESL_NEWSSI **ret_newssi)
    int esl_newssi_AddFile(ESL_NEWSSI *ns, char *filename, int fmt, uint16_t* ret_fh)
    int esl_newssi_AddKey(ESL_NEWSSI *ns, char *key, int fh, int r_off, int d_off, long L)
    int esl_newssi_Write(ESL_NEWSSI *ns)
    void esl_newssi_Close(ESL_NEWSSI *ns)

cdef enum EaselErrors:
    eslOK = 0    # no error/success
    eslFAIL = 1    # failure
    eslEOL = 2    # end-of-line (often normal)
    eslEOF = 3    # end-of-file (often normal)
    eslEOD = 4    # end-of-data (often normal)
    eslEMEM = 5    # malloc or realloc failed
    eslENOTFOUND = 6    # file or key not found
    eslEFORMAT = 7    # file format not correct
    eslEAMBIGUOUS = 8    # an ambiguity of some sort
    eslEDIVZERO = 9    # attempted div by zero
    eslEINCOMPAT = 10    # incompatible parameters
    eslEINVAL = 11    # invalid argument/parameter
    eslESYS = 12    # generic system call failure
    eslECORRUPT = 13    # unexpected data corruption
    eslEINCONCEIVABLE = 14    # "can't happen" error
    eslESYNTAX = 15    # invalid user input syntax
    eslERANGE = 16    # value out of allowed range
    eslEDUP = 17    # saw a duplicate of something
    eslENOHALT = 18    # a failure to converge
    eslENORESULT = 19    # no result was obtained
    eslENODATA = 20    # no data provided, file empty
    eslETYPE = 21    # invalid type of argument
    eslEOVERWRITE = 22    # attempted to overwrite data
    eslENOSPACE = 23    # ran out of some resource
    eslEUNIMPLEMENTED = 24    # feature is unimplemented

cdef int SQFILE_UNKNOWN = 0
cdef int SQFILE_FASTA = 1
cdef int SQFILE_EMBL = 2
cdef int SQFILE_GENBANK = 3
cdef int SQFILE_NCBI = 6
