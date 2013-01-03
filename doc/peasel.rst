API documentation
=================

``peasel`` Module
-----------------

.. currentmodule:: peasel

.. automodule:: peasel
   :members: create_ssi, open_ssi, read_seq_file, write_fasta

   .. autoclass:: EaselSequence

      .. automethod:: __len__(self)

         Length of the sequence

      .. automethod:: __getitem__(self, s)

      .. automethod:: create(name, residues, accession, description)

      .. attribute:: name

          Sequence identifier

      .. attribute:: seq

          Sequence
