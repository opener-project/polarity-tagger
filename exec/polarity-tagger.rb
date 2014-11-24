#!/usr/bin/env ruby

require 'opener/daemons'

require_relative '../lib/opener/polarity_tagger'

daemon = Opener::Daemons::Daemon.new(Opener::PolarityTagger)

daemon.start
