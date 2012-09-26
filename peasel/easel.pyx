cimport ceasel

__all__ = ['read_seq_file', 'create_ssi', 'open_ssi',
        'FMT_FASTA', 'write_fasta']

FMT_FASTA = SQFILE_FASTA
FMT_GENBANK = SQFILE_GENBANK

class EaselError(ValueError):
    pass

cdef class EaselSequence:
    """
    Wrapper for the Easel ESL_SQ object
    """

    cdef ceasel.ESL_SQ *_sq

    def __dealloc__(self):
        if self._sq is not NULL:
            ceasel.esl_sq_Destroy(self._sq)

    property name:
        def __get__(self):
            return self._sq.name
        def __set__(self, bytes name):
            ceasel.esl_sq_SetName(self._sq, name)
    property acc:
        def __get__(self):
            return self._sq.acc
        def __set__(self, bytes acc):
            ceasel.esl_sq_SetAccession(self._sq, acc)
    property desc:
        def __get__(self):
            return self._sq.desc
        def __set__(self, bytes desc):
            ceasel.esl_sq_SetDesc(self._sq, desc)
    property seq:
        def __get__(self):
            return self._sq.seq
    def __len__(self):
        return self._sq.n

    def write(self, file f):
        """
        Write the sequence to open file handle f, in FASTA format
        """
        r = esl_sqio_Write(PyFile_AsFile(f), self._sq, SQFILE_FASTA, 0)
        if r != eslOK:
            raise EaselError("Write failed with {0}".format(r))

    def reverse_complement(self):
        """
        Reverse complements the sequence, in place
        """
        cdef int res = ceasel.esl_sq_ReverseComplement(self._sq)

        if res != eslOK:
            raise EaselError("Error reverse complementing ({0})".format(res))

    def copy(self):
        """
        Make a copy of this sequence
        """
        cdef int res

        cdef ceasel.ESL_SQ *s = ceasel.esl_sq_Create()
        try:
            res = esl_sq_Copy(self._sq, s)
            if res != eslOK:
                raise EaselError("Error Copying ({0})".format(res))
            sq = EaselSequence()
            sq._sq = s
            return sq
        except:
            esl_sq_Destroy(s)
            raise

    def __getitem__(self, slice s):
        cdef bytes seq

        seq = self._sq.seq
        seq = seq[s]
        return create_easel_sequence(ceasel.esl_sq_CreateFrom(self._sq.name, seq, self._sq.acc, self._sq.desc, NULL))

    @classmethod
    def create(cls, bytes name, bytes seq, bytes acc, bytes desc):
        return create_easel_sequence(ceasel.esl_sq_CreateFrom(name, seq, acc, desc, NULL))

cdef create_easel_sequence(ceasel.ESL_SQ *_sq):
    s = EaselSequence()
    s._sq = _sq
    return s

cdef ceasel.ESL_SQFILE* open_sequence_file(bytes path, int sq_format=SQFILE_UNKNOWN) except NULL:
    cdef ceasel.ESL_SQFILE *sq_fp = NULL
    cdef int status
    status = ceasel.esl_sqfile_Open(path, 1, NULL, &sq_fp)
    if status == eslENOTFOUND:
        raise IOError("Not found: {0}".format(path))
    elif status != eslOK:
        raise IOError("Failed to create: {0}".format(status))
    return sq_fp

cdef int _open_ssi(ESL_SQFILE* sqfp) except -1:
    cdef int status
    status = ceasel.esl_sqfile_OpenSSI(sqfp, NULL)
    if status == eslENOTFOUND:
        raise IOError("SSI Index Not found.")
    if status == eslEFORMAT:
        raise IOError("Incorrect format!")
    if status == eslERANGE:
        raise IOError("Incorrect format (64-bit)!")
    elif status != eslOK:
        raise IOError("Failed to create: {0}".format(status))
    return 0

cdef ceasel.ESL_SQ* read_sequence(ESL_SQFILE *sq_fp) except NULL:
    cdef ceasel.ESL_SQ *sq = ceasel.esl_sq_Create()
    cdef int status
    status = ceasel.esl_sqio_Read(sq_fp, sq)
    if status != eslOK:
        ceasel.esl_sq_Destroy(sq)
        raise IOError("Error reading sequence [{0}]".format(status))
    return sq

def read_seq_file(bytes path, int sq_format=SQFILE_UNKNOWN):
    cdef ceasel.ESL_SQFILE *sq_fp = open_sequence_file(path, sq_format)
    cdef ceasel.ESL_SQ *sq = ceasel.esl_sq_Create()
    try:
        while ceasel.esl_sqio_Read(sq_fp, sq) == eslOK:
            yield create_easel_sequence(sq)
            sq = ceasel.esl_sq_Create()
    finally:
        ceasel.esl_sq_Destroy(sq)
        ceasel.esl_sqfile_Close(sq_fp)


cdef class EaselSequenceIndex:
    cdef ceasel.ESL_SQFILE *_sq_fp
    cdef bytes file_path
    cdef int sq_format

    def __getitem__(self, bytes key):
        cdef int status

        status = ceasel.esl_sqfile_PositionByKey(self._sq_fp, key)
        if status == eslENOTFOUND:
            raise KeyError("Sequence {0} not found in index for file {1}".format(key, self.file_path))
        elif status == eslEFORMAT:
            raise IOError("Failed to parse SSI index for {0}".format(self.file_path))
        elif status != eslOK:
            raise IOError("Failed to look up {0} in {1} [{2}]".format(key, self.file_path, status))

        sq = read_sequence(self._sq_fp)
        return create_easel_sequence(sq)

    def __dealloc__(self):
        if self._sq_fp is not NULL:
            ceasel.esl_sqfile_Close(self._sq_fp)

def open_ssi(bytes file_path, int sq_format=SQFILE_UNKNOWN):
    """
    Open a simple sequence index for a file.
    """
    obj = EaselSequenceIndex()
    obj.file_path = file_path
    obj.sq_format = sq_format
    obj._sq_fp = open_sequence_file(file_path, sq_format)
    _open_ssi(obj._sq_fp)

    if obj._sq_fp.data.ascii.ssi is NULL:
        raise IOError("no index exists for {0}".format(file_path))

    return obj


def create_ssi(bytes file_path, bytes ssi_name=None, int sq_format=SQFILE_UNKNOWN):
    """
    Create a Simple Sequence Index for a file.
    """
    cdef ceasel.ESL_NEWSSI *ssi
    cdef ceasel.ESL_SQFILE *sq_fp = NULL
    cdef ceasel.ESL_SQ *sq = esl_sq_Create()
    cdef int status, count = 0
    cdef ceasel.uint16_t fh

    if ssi_name is None:
        ssi_name = file_path + '.ssi'

    status = esl_newssi_Open(ssi_name, 0, &ssi);

    if status == eslENOTFOUND:
        raise IOError("Not found: {0}".format(ssi_name))
    elif status == eslEOVERWRITE:
        raise IOError("Exists: {0}".format(ssi_name))
    elif status != eslOK:
        raise IOError("Failed to create: {0}".format(status))

    status = esl_sqfile_Open(file_path, 1, NULL, &sq_fp)
    if status != eslOK:
        raise IOError("Error opening {0}: {1}".format(file_path, status))

    if esl_newssi_AddFile(ssi, sq_fp.filename, sq_fp.format, &fh) != eslOK:
        raise IOError("Failed to add sequence file {0}".format(file_path))

    try:
        status = ceasel.esl_sqio_ReadInfo(sq_fp, sq)
        while status == eslOK:
            count += 1
            if esl_newssi_AddKey(ssi, sq.name, fh, sq.roff, sq.doff, sq.L) != eslOK:
                raise EaselError("unable to add %s to index", sq.name)
            esl_sq_Reuse(sq)
            status = ceasel.esl_sqio_ReadInfo(sq_fp, sq)
        if status == eslEFORMAT:
            raise IOError("Failed parsing.")
        elif status != eslEOF:
            raise IOError(
                    "Unexpected error {0} reading sequence file".format(status))

        esl_newssi_Write(ssi)
    finally:
        ceasel.esl_sq_Destroy(sq)
        ceasel.esl_sqfile_Close(sq_fp)
        ceasel.esl_newssi_Close(ssi)

    return count

def write_fasta(sequences not None, file fp not None):
    """
    Writes `sequences` to the open file handle fp
    """
    cdef int count
    for sequence in sequences:
        count += 1
        sequence.write(fp)
    return count
