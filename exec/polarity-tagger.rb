#!/usr/bin/env ruby

require 'opener/daemons'
require 'opener/core'

require_relative '../lib/opener/polarity_tagger'

switcher      = Opener::Core::ResourceSwitcher.new
switcher_opts = {}

parser = Opener::Daemons::OptParser.new do |opts|
  switcher.bind(opts, switcher_opts)
end

options = parser.parse!(ARGV)
daemon  = Opener::Daemons::Daemon.new(Opener::PolarityTagger, options)

switcher.install(switcher_opts)
daemon.start
