# `peasely`

Some wrappers for a little bit of  [Sean Eddy](http://selab.janelia.org/)'s excellent [Easel](http://selab.janelia.org/people/eddys/blog/?p=394) library for sequence manipulation.

At present, it's just a Python API to the Simple Sequence Index (SSI) format.

Requires [Cython](http://www.cython.org/) for development.

# Usage

## Create an index file

Use `peasel.create_ssi` to build a sequence index:

```python
>>> import peasel
>>> peasel.create_ssi('my_big_sequence_file.fasta') # creates my_big_sequence_file.fasta.ssi
2 # Number of sequences indexed
```

## Retrieving sequences from an index

Sequence-indexes support dict-like behavior:

```python
>>> import peasel
>>> # Open the index
>>> index = peasel.open_ssi('my_big_sequence_file.fasta')
>>> seq = index['sequence1']
>>> seq
<peasel.ceasel.EaselSequence object at 0x7f7c59558150>
```


# License

Distributed under the GPLv3
