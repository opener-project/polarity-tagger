#!/usr/bin/env python

##############################
#                            #
# Polarity tagger for dutch,english and German  #
# 22-jan-2013: added code for reading the language code and create the lexicon
#
##############################

__desc='VUA polarity tagger multilanguage'
__last_edited='21may2014'
VERSION="1.2"


from collections import defaultdict
import sys
import os
import argparse
import logging

this_folder = os.path.dirname(os.path.realpath(__file__))

# This updates the load path to ensure that the local site-packages directory
# can be used to load packages (e.g. a locally installed copy of lxml).
sys.path.append(os.path.join(this_folder, 'site-packages/pre_install'))


from lxml import etree
from VUKafParserPy import KafParser
from VUSentimentLexicon import LexiconSent, show_lexicons

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

    ##CLI options
    argument_parser = argparse.ArgumentParser(description='Tags a text with polarities at lemma level')
    argument_parser.add_argument("--no-time",action="store_false", default=True, dest="my_time_stamp",help="For not including timestamp in header")
    argument_parser.add_argument("--ignore-pos", action="store_true", default=False , dest="ignore_pos", help="Ignore the pos labels")
    argument_parser.add_argument("--show-lexicons", action="store", choices = ('nl','en','de','es','it','fr'), default=None,dest='show_lexicons',help="Show lexicons for the given language and exit")
    argument_parser.add_argument("--lexicon", action="store", default=None, dest="lexicon", help="Lexicon identifier, check with --show-lexicons LANG for options")
    argument_parser.add_argument("--lexicon-path", action="store", default=None, dest="lexicon_path", help="The path of the lexicons")
    argument_parser.add_argument("--silent",dest="silent",action='store_true', help='Turn off debug info')
    argument_parser.add_argument('--version', action='version', version='%(prog)s '+VERSION)

    arguments = argument_parser.parse_args()
    #############

    if arguments.show_lexicons is not None:
        show_lexicons(arguments.show_lexicons, arguments.lexicon_path)
        sys.exit(0)

    logging.basicConfig(stream=sys.stderr,format='%(asctime)s - %(levelname)s - %(message)s',level=logging.DEBUG)

    if arguments.silent:
        logging.getLogger().setLevel(logging.ERROR)


    numNegators = 0
    ## READ the data and create structure for terms
    if not sys.stdin.isatty():
        ## READING FROM A PIPE
        logging.debug('Reading from standard input')
        fic = sys.stdin
    else:
        print>>sys.stderr,'Input stream required.'
        print>>sys.stderr,'Example usage: cat myUTF8file.kaf.xml |',sys.argv[0]
        print>>sys.stderr,sys.argv[0]+' -h  for help'
        sys.exit(-1)




    kafParserObj = KafParser(fic)

    for term in kafParserObj.getTerms():
      terms.append(term)



    logging.debug('Number of terms loaded '+str(len(terms)))


    ## Load lexicons

    lang = kafParserObj.getLanguage()
    ##lexSent = LexiconSent(lang,'general')
    lexSent = LexiconSent(lang,arguments.lexicon,arguments.lexicon_path)  ##Default lexicons
    ################


    ## For each term, establish its sentiment polarity
    acc_polarity = defaultdict(int)

    for term in terms:
      lemma = term.getLemma()
      if lemma!=None:
        lemma = lemma.lower()

      kaf_pos = term.getPos()
      if arguments.ignore_pos:
        kaf_pos = None
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


    kafParserObj.addLinguisticProcessor(__desc,__last_edited+'_'+VERSION,'terms', arguments.my_time_stamp)
    kafParserObj.saveToFile(sys.stdout)
