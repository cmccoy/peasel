API documentation
=================

``peasel`` Module
-----------------

.. currentmodule:: peasel

.. automodule:: peasel

   .. autoclass:: EaselSequence

      .. automethod:: __len__(self)

         Length of the sequence

      .. automethod:: __getitem__(self, s)

      .. automethod:: create(name, residues, accession, description)

      .. attribute:: name

          Sequence identifier

      .. attribute:: seq

          Sequence

  .. autofunction:: create_ssi(file_path, ssi_name=None, sq_format=SQFILE_UNKNOWN)

  .. autofunction:: open_ssi(file_path, ssi_path=None, sq_format=SQFILE_UNKNOWN)

  .. autofunction:: read_fasta(path)

  .. autofunction:: read_seq_file(path, sq_format=SQFILE_UNKNOWN)

  .. autofunction:: write_fasta(sequences, fp)
