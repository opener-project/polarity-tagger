desc 'Verifies the requirements'
task :requirements do
  require 'cliver'

  Cliver.detect! 'python2', '~> 2.6'
  Cliver.detect! 'pip2', '>= 1.3'
end
