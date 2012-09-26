.PHONY : clean inplace build clean-backupfiles clean-patchfiles clean-pyc

inplace: peasel/ceasel.so

peasel/ceasel.so: peasel/easel.pyx peasel/ceasel.pxd
	python setup.py build_ext --inplace

build:
	python setup.py build

clean:
	python setup.py clean
	rm -rf build
	rm -f peasel/ceasel.so

clean: clean-pyc clean-patchfiles clean-backupfiles

clean-pyc:
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +

clean-patchfiles:
	find . -name '*.orig' -exec rm -f {} +
	find . -name '*.rej' -exec rm -f {} +

clean-backupfiles:
	find . -name '*~' -exec rm -f {} +
	find . -name '*.bak' -exec rm -f {} +
