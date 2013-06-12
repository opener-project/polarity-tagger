#!/usr/bin/env python

##############################
#                            #
# Polarity tagger for dutch,english and German  #
# 22-jan-2013: added code for reading the language code and create the lexicon
#
##############################

from collections import defaultdict
import sys
import os
import getopt
import logging

this_folder = os.path.dirname(os.path.realpath(__file__))

# This updates the load path to ensure that the local site-packages directory
# can be used to load packages (e.g. a locally installed copy of lxml).
sys.path.append(os.path.join(this_folder, 'site-packages/pre_build'))
sys.path.append(os.path.join(this_folder, 'site-packages/pre_install'))

from VUKafParserPy import KafParser
from VUSentimentLexicon import LexiconSent

logging.basicConfig(stream=sys.stderr,format='%(asctime)s - %(levelname)s - %(message)s',level=logging.DEBUG)


def calculateOverallPolarity(accPol,numNegators):
  guess='neutral'

  totalPositive = accPol['positive'] + 2*accPol['positive positive']
  totalNegative = accPol['negative'] + 2*accPol['negative negative'] + numNegators

  if totalPositive==0 and totalNegative==0:  guess='neutral'
  elif totalPositive > totalNegative: guess='positive'
  elif totalPositive < totalNegative: guess='negative'
  elif numNegators>0: guess='negative'
  else: guess='neutral'

  return guess



if __name__ == '__main__':

    terms = []
    logging.basicConfig(stream=sys.stderr,format='%(asctime)s - %(levelname)s - %(message)s',level=logging.DEBUG)



    numNegators = 0
    ## READ the data and create structure for terms
    if not sys.stdin.isatty():
        ## READING FROM A PIPE
        logging.debug('Reading from standard input')
        fic = sys.stdin
    else:
        print>>sys.stderr,'Input stream required.'
        print>>sys.stderr,'Example usage: cat myUTF8file.kaf.xml |',sys.argv[0]
        sys.exit(-1)

    my_time_stamp = True
    try:
      opts, args = getopt.getopt(sys.argv[1:],"",["no-time"])
      for opt, arg in opts:
        if opt == "--no-time":
          my_time_stamp = False
    except getopt.GetoptError:
      pass

    kafParserObj = KafParser(fic)

    for term in kafParserObj.getTerms():
      terms.append(term)



    logging.debug('Number of terms loaded'+str(len(terms)))


    ## Load lexicons

    lang = kafParserObj.getLanguage()
    lexSent = LexiconSent(lang)
    ################


    ## For each term, establish its sentiment polarity
    acc_polarity = defaultdict(int)

    for term in terms:

      lemma = term.getLemma().lower()

      kaf_pos = term.getPos()

      sentiment_attribs = {}

      ## POLARITY
      polarity, polarity_pos = lexSent.getPolarity(lemma,kaf_pos)
      if polarity!='unknown':
        sentiment_attribs['polarity']=polarity

      ## NEGATORS
      if lexSent.isNegator(lemma):
        numNegators+=1
        sentiment_attribs['sentiment_modifier']='shifter'
        polarity_pos=None

      ## INTENSIFIERS
      if lexSent.isIntensifier(lemma):
        sentiment_attribs['sentiment_modifier']='intensifier'
        polarity_pos=None


      if len(sentiment_attribs) != 0:
        sentiment_attribs['resource']=lexSent.getResource()
        kafParserObj.addPolarityToTerm(term.getId(),sentiment_attribs,polarity_pos)
      acc_polarity[polarity]+=1

      ## Next term
      previousLemma = lemma


    kafParserObj.addLinguisticProcessor('Basic_polarity_tagger_with_pos','1.0','terms',time_stamp=my_time_stamp)
    kafParserObj.saveToFile(sys.stdout)
