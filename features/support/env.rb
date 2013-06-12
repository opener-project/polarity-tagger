require_relative '../../lib/opener/polarity_tagger'
require 'rspec/expectations'

def kernel
  return Opener::PolarityTagger.new(:args => ['--no-time'])
end
