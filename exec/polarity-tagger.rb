#!/usr/bin/env ruby

require 'opener/daemons'
require_relative '../lib/opener/polarity_tagger'

options = Opener::Daemons::OptParser.parse!(ARGV)
daemon  = Opener::Daemons::Daemon.new(Opener::PolarityTagger, options)

daemon.start