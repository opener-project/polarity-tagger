Introduction
------------

This repository contains the code for the OpeNER polarity tagger. This tool tags words in a KAF file with polarity information, which basically is:

* Polarity information, which represents positive or negative facts in a certain domain. Good, cheap and clean can be positive words in a hotel domain, while bad, expensive and dirty could be negative ones.
* Sentiment modifiers, which modify the polarity of a surrounding polarity word. For instance very or no are sentiment modifiers

The polarity tagger supports the following languages:

* Dutch
* German
* English
* French
* Italian
* Spanish

### Confused by some terminology?

This software is part of a larger collection of natural language processing tools known as "the OpeNER project". You can find more information about the project at [the OpeNER portal](http://opener-project.github.io). There you can also find references to terms like KAF (an XML standard to represent linguistic annotations in texts), component, cores, scenario's and pipelines.

Quick Use Example
-----------------

Installing the polarity-tagger can be done by executing:

    gem install opener-polarity-tagger

The polarity tagger uses python. So it is advised to run a virtualenv before installing the gem.

Please bare in mind that all components in OpeNER take KAF as an input and output KAF by default.

### Command line interface

You should now be able to call the polarity tagger as a regular shell command: by its name. Once installed the gem normally sits in your path so you can call it directly from anywhere.

This aplication reads a text from standard input in order process it.

    cat some_kind_of_kaf_file.kaf | polarity-tagger


This will output:

```
<term lemma="donner" morphofeat="VP3s" pos="V" tid="t119" type="open">
  <span>
    <!--donne-->
    <target id="w119"/>
  </span>
  <sentiment polarity="neutral" resource="General domain lexicon for French . Vicomtech_general_lexicon_french"/>
</term>
```

### Webservices

You can launch a webservice by executing:

    polarity-tagger-server

This will launch a mini webserver with the webservice. It defaults to port 9292, so you can access it at <http://localhost:9292>.

To launch it on a different port provide the `-p [port-number]` option like this:

    polarity-tagger-server -p 1234

It then launches at <http://localhost:1234>

Documentation on the Webservice is provided by surfing to the urls provided above. For more information on how to launch a webservice run the command with the ```-h``` option.


### Daemon

Last but not least the polarity tagger comes shipped with a daemon that can read jobs (and write) jobs to and from Amazon SQS queues. For more information type:

    polarity-tagger-daemon -h


Description of dependencies
---------------------------

This component runs best if you run it in an environment suited for OpeNER components. You can find an installation guide and helper tools in the [OpeNER installer](https://github.com/opener-project/opener-installer) and an [installation guide on the Opener Website](http://opener-project.github.io/getting-started/how-to/local-installation.html)

At least you need the following system setup:

### Depenencies for normal use:

* Ruby 1.9.3 or newer
* Python 2.6 or newer
* Lxml installed

Domain Adaption
---------------

  TODO

Language Extension
------------------

  TODO

The Core
--------

The component is a fat wrapper around the actual language technology core. You can find the core technolies in the ``\`core/``` folder.

Where to go from here
---------------------

* [Check the project websitere](http://opener-project.github.io)
* [Checkout the webservice](http://opener.olery.com/polarity-tagger)

Report problem/Get help
-----------------------

If you encounter problems, please email <support@opener-project.eu> or leave an issue in the 
[issue tracker](https://github.com/opener-project/polarity-tagger/issues).


Contributing
------------

1. Fork it <http://github.com/opener-project/polarity-tagger/fork>
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

