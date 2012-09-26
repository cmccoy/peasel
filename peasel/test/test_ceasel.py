import unittest
import tempfile
import os
import os.path

from peasel import ceasel


class SequenceFileMixIn(object):
    def setUp(self):
        with tempfile.NamedTemporaryFile(suffix='.fasta', delete=False) as tf:
            self.file_path = tf.name
            tf.write(""">sequence1 d1
ACCGT
>sequence2 description2
ACGTTTTT
""")
        self.ssi_path = self.file_path + '.ssi'

    def tearDown(self):
        for f in [self.file_path, self.ssi_path]:
            if os.path.exists(f):
                os.unlink(f)

class CreateSSITestCase(SequenceFileMixIn, unittest.TestCase):

    def test_ssi_create(self):
        res = ceasel.create_ssi(self.file_path)
        self.assertEqual(2, res, msg='2 sequences indexed')
        self.assertTrue(os.path.isfile(self.ssi_path))

    def test_ssi_create_nooverrwrite(self):
        ceasel.create_ssi(self.file_path)
        self.assertTrue(os.path.isfile(self.ssi_path))
        self.assertRaises(IOError, ceasel.create_ssi, self.file_path)

class EaselSequenceIndexTestCase(SequenceFileMixIn, unittest.TestCase):

    def test_nossi_errors(self):
        self.assertRaises(IOError, ceasel.open_ssi, self.file_path)

    def test_ssi_fetch(self):
        ceasel.create_ssi(self.file_path)
        index = ceasel.open_ssi(self.file_path)
        seq1 = index['sequence1']
        self.assertTrue(seq1 is not None)
        self.assertEqual(5, len(seq1))
        self.assertEqual('sequence1', seq1.name)
        self.assertEqual('d1', seq1.desc)
        self.assertEqual('ACCGT', seq1.seq)

        seq2 = index['sequence2']
        self.assertTrue(seq2 is not None)

    def test_ssi_fetch_keyerror(self):
        ceasel.create_ssi(self.file_path)
        index = ceasel.open_ssi(self.file_path)
        self.assertRaises(KeyError, index.__getitem__, 'sequence3')

class EaselSequenceTestCase(unittest.TestCase):

    def setUp(self):
        self.sequence = ceasel.EaselSequence.create('test', 'ACCGT', '', '')

    def test_slice(self):
        sequence = self.sequence
        self.assertEqual(3, len(sequence[:3]))
        self.assertEqual('CCG', sequence[1:4].seq)

    def test_set_name(self):
        sequence = self.sequence
        sequence.name = 'NEW NAME'
        self.assertEqual(sequence.name, 'NEW NAME')

    def test_copy(self):
        sequence = self.sequence.copy()
        self.assertNotEqual(sequence, self.sequence)
        self.assertEqual(sequence.seq, self.sequence.seq)

    def test_reverse_complement(self):
        self.sequence.reverse_complement()
        self.assertEqual('ACGGT', self.sequence.seq)

