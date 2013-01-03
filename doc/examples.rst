Example Usage
=============

Create an index file
--------------------

Use ``peasel.create_ssi`` to build a sequence index:

::

    >>> import peasel
    >>> peasel.create_ssi('my_big_sequence_file.fasta') # creates my_big_sequence_file.fasta.ssi
    2 # Number of sequences indexed

Retrieving sequences from an index
----------------------------------

Sequence-indexes support ``dict``-like behavior:

::

    >>> import peasel
    >>> # Open the index
    >>> index = peasel.open_ssi('my_big_sequence_file.fasta')
    >>> index['sequence1']
    <EaselSequence 0x7f38735b80f0 [name="sequence1";description="";length=5]>
    >>> index.get('sequence1')
    <EaselSequence 0x7f38735b8108 [name="sequence1";description="";length=5]>
    >>> print index.get('missing_sequence')
    None

Using a temporary index
-----------------------

If you'd prefer not to litter the filesystem with ``.ssi`` files, use
the ``temp_ssi`` context manager:

::

    >>> import peasel
    >>> with peasel.temp_ssi('my_big_sequence_file.fasta') as index:
    ...     index['sequence1']
    ...
    <EaselSequence 0x7ff15065a0f0 [name="sequence1";description="";length=5]>
