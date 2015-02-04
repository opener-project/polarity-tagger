require 'optparse'
require 'csv'
require 'oga'
require 'rexml/document'
require 'rexml/formatters/pretty'
require 'benchmark'

options  = {}
lexicons = []

OptionParser.new do |opts|
  opts.banner = "Usage: generate_lexicons [options]"

  opts.on("-i", "--input FILE", "Input FILE") do |i|
    options[:input] = i
  end

  opts.on("-o", "--output FILE", "Output FILE") do |o|
    options[:output] = o
  end

  opts.on("--append", "Appends the generated lexicons to the existing output") do |a|
    options[:append] = a
  end

  opts.on("-h", "--help", "Display this screen") do
    puts opts
    exit
  end
end.parse!

def read_lexicons(file)
  output = []

  CSV.foreach(file, {:headers => true}) do |row|
    output << {
      :lemma    => row["lemma"],
      :polarity => row["polarity"],
      :language => row["language"],
      :pos      => row["pos"],
      :strength => row["strength"]
    }
  end

  return output
end

def write_to_file(file, lexicons, option)
  document = Oga.parse_xml(File.open(file))
  entries  = document.at_xpath('LexicalResource/Lexicon').children

  lexicons.each do |lexicon|
    entries << new_node(lexicon)
  end

  File.open(file, 'w+') do |f|
    f.puts pretty_print(document)
  end
end

def new_node(lexicon)
  node  = new_element('LexicalEntry')
  node.set('id', '')
  node.set('partOfSpeech', lexicon[:pos])

  node.children << lemma(lexicon)
  node.children << sense(lexicon)

  return node
end

def lemma(lexicon)
  node = new_element('Lemma')

  node.set('writtenForm', lexicon[:lemma])

  return node
end

def sense(lexicon)
  node      = new_element('Sense')

  node.children << confidence
  node.children << monolingual
  node.children << sentiment(lexicon)
  node.children << domain

  return node
end

def sentiment(lexicon)
  node = new_element('Sentiment')

  strength  = check_strength(lexicon[:strength])

  node.set('polarity', lexicon[:polarity])
  node.set('strength', strength) if strength

  return node
end

def monolingual
  node = new_element('MonolingualExternalRef')

  return node
end

def confidence
  node = new_element('Confidence')

  node.set('level', 'automatic')

  return node
end

def domain
  node = new_element('domain')

  return node
end

def check_strength(value)
  string = nil

  if value.to_i == 1
    string = "average"
  elsif value.to_i >= 2
    string = "strong"
  end

  return string
end

def new_element(name)
  return Oga::XML::Element.new(:name => name)
end

##
# Format the output document properly.
#
# TODO: this should be handled by Oga in a nice way.
#
# @return [String]
#
def pretty_print(document)
  doc = REXML::Document.new document.to_xml
  doc.context[:attribute_quote] = :quote
  out = ""
  formatter = REXML::Formatters::Pretty.new
  formatter.compact = true
  formatter.write(doc, out)

  return out.strip
end

lexicons = read_lexicons(options[:input])
write_to_file(options[:output], lexicons, options[:append])

