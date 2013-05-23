VU-polarity-tagger-basic_ALL-LANGS_kernel
==================================

This module implements a polarity tagger for all the languages of the Opener Project (Dutch, German, English, French, Italian and Spanish). The language
is determined by the "xml:lang" attribute in the input KAF file. Depending on the value of this attribute,
the corresponding lexicon will be loaded.

Requirements
-----------
* VUKafParserPy: parser in python for KAF files
* VUSentimentLexicon: library to handle the lexicons (in xml format). 
* lxml: library for processing xml in python


Installation
-----------
This module implements a polarity tagger for all the OpeNER languages, but does not contain the lexical resources and lexicons. These lexicons are
contained in another repository which acts as a library for loading and querying the lexicons, the VU-sentiment-lexicon (https://github.com/opener-project/VU-sentiment-lexicon).
This library needs to be installed before using the polarity tagger. The detailed instructions are in the README of that repository, but briefly:

````shell
git clone git@github.com:opener-project/VU-sentiment-lexicon.git
cd VU-sentiment-lexicon
sudo python setup.py install
````

With these commands we will have the repository installed in our machine and available to be used for other repositories. Also the VUKafParserPy is required to parse KAF files,
which is contained on the repository https://github.com/opener-project/VU-kaf-parser. For the installation of this library:

````shell
git clone git@github.com:opener-project/VU-kaf-parser.git
cd VU-kaf-parser
sudo python setup.py install
````

The last step is to install the library lxml. If you have pip installed on your machine, you can install easily lxml by running:
````shell
pip install lxml
````

Finally for the polarity tagger there is no need of specific installation, just clone the repository to your local machine and begin using it.
````
git clone git@github.com:opener-project/VU-polarity-tagger-basic_ALL-LANGS_kernel.git
````


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