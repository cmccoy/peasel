# `peasel`

Some python wrappers for a little bit of  [Sean Eddy](http://selab.janelia.org/)'s excellent [Easel](http://selab.janelia.org/people/eddys/blog/?p=394) library for sequence manipulation.

At present, it's just a Python API to the Simple Sequence Index (SSI) format
for rapid sequence retrieval from large files.

# Installation

`peasel` requires [Python 2.7](http://www.python.org/), either
[setuptools](http://pypi.python.org/pypi/setuptools) or
[distribute](http://pypi.python.org/pypi/distribute) and a working C compiler.

Development requires [Cython](http://www.cython.org/), tested with version 0.17.

To install:

```sh
pip install peasel
```

Or for the cutting edge version:
```sh
pip install https://github.com/cmccoy/peasel/archive/master.tar.gz
```

To run the unit tests:

```sh
python setup.py test
```

# Usage

## Create an index file

Use `peasel.create_ssi` to build a sequence index:

```python
>>> import peasel
>>> peasel.create_ssi('my_big_sequence_file.fasta') # creates my_big_sequence_file.fasta.ssi
2 # Number of sequences indexed
```

## Retrieving sequences from an index

Sequence-indexes support `dict`-like behavior:

```python
>>> import peasel
>>> # Open the index
>>> index = peasel.open_ssi('my_big_sequence_file.fasta')
>>> index['sequence1']
<EaselSequence 0x7f38735b80f0 [name="sequence1";description="";length=5]>
>>> index.get('sequence1')
<EaselSequence 0x7f38735b8108 [name="sequence1";description="";length=5]>
>>> print index.get('missing_sequence')
None
```

## Using a temporary index

If you'd prefer not to litter the filesystem with `.ssi` files, use the `temp_ssi` context manager:

```python
>>> import peasel
>>> with peasel.temp_ssi('my_big_sequence_file.fasta') as index:
...     index['sequence1']
...
<EaselSequence 0x7ff15065a0f0 [name="sequence1";description="";length=5]>
```

# License

Distributed under the GPLv3. Easel source code is distributed under the Janelia
Farm License, included in the `easel-src` subdirectory.
