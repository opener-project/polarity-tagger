VU-polarity-tagger-basic_ALL-LANGS_kernel
==================================

This module implements a polarity tagger for all the languages of the Opener Project (Dutch, German, English, French, Italian and Spanish). The language
is determined by the "xml:lang" attribut in the input KAF file. Depending on the value of this attribute,
the corresponding lexicon will be loaded.

Requirements
-----------
* VUKafParserPy: parser in python for KAF files
* VUSentimentLexicon: library to handle the lexicons (in xml format)
* lxml: library for processing xml in python


Usage
----

The input KAF file has to be annotated with at least the term layer (with pos information).
Correct input files for this module are the output KAF files from the POS tagger modules.

To tag an input KAF file example.kaf with polarities you can run:
````shell
$ cat example.kaf | core/poltagger-basic-multi.py > output.with.polarities.kaf
````

Contact
------  
* Ruben Izquierdo
* Vrije University of Amsterdam
* ruben.izquierdobevia@vu.nl