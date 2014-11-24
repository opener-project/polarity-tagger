## Reference

#### Examples:

##### Simple polarity tagging

Example command:

    cat some-kaf-file.kaf | polarity-tagger

Partial output:

    <term lemma="donner" morphofeat="VP3s" pos="V" tid="t119" type="open">
      <span>
        <!--donne-->
        <target id="w119"/>
      </span>
      <sentiment polarity="neutral" resource="General domain lexicon for French . Vicomtech_general_lexicon_french"/>
    </term>

#### Switching to another lexicon

    cat some-kaf-file.kaf | polarity-tagger --resource-path path/to/lexicon

#### Downloading and switching to lexicon

    cat some-kaf-file.kaf | polarity-tagger \
      --resource_path path/to/extract/lexicon \
      --resource-url http://some.kind.of/zip-file.zip

#### Disabling pos matching

To push options to the python core use a double dash (--)

    cat some-kaf.kaf | polarity-tagger -- --no-pos

#### Getting to the core

The main script of this tool is a python file, which accepts a set of parameters
to determine which features or options we want to use. The language is read from
the KAF file, so it doesn't need to be specified as a parameter. The program
reads a KAF file from the standard input and writes the resulting KAf in the
standard output.To see the options you can call to the main script with the -h
or --help option

    polarity-tagger -- -h
    usage: poltagger-basic-multi.py [-h] [--no-time] [--ignore-pos]
                                [--show-lexicons {nl,en,de,es,it,fr}]
                                [--lexicon LEXICON] [--silent] [--version]

Tags a text with polarities at lemma level

Options:

    -h, --help            show this help message and exit
    --no-time             For not including timestamp in header
    --ignore-pos          Ignore the pos labels
    --show-lexicons {nl,en,de,es,it,fr}
                          Show lexicons for the given language and exit
    --lexicon LEXICON     Lexicon identifier, check with --show-lexicons LANG
                          for options
    --silent              Turn off debug info
    --version             show program's version number and exit

The `--ignore-pos` parameter must be used when want to ignore the part-of-speech
information assigned to the lemmas, and we want to assign polarities just to the
lemmas, not considering the POS tag. This could be useful when the information
provided by the pos-tagger is not accurate or the pos-tagging has not been
processed.

The main options are those concerning with the usage of different lexicons. The
lexicons are provided by the VU-sentiment-lexicon library
(<https://github.com/opener-project/VU-sentiment-lexicon>), which needs to be
installed. You can see what the lexicons available for a given language are by
calling to the program with the option --show-lexicons LANG, for instance:

    polarity-tagger -- --show-lexicons nl

Available lexicons for nl:

    Identifier: "hotel" (Default)
      Desc: Hotel domain lexicon for Dutch
       Res: VUA_olery_lexicon_nl_lmf
      File: /Users/ruben/python_envs/python2.7/lib/python2.7/VUSentimentLexicon/NL-lexicon/Sentiment-Dutch-HotelDomain.xml

    Identifier:"general"
      Desc: General lexicon for Dutch
       Res: VUA_olery_lexicon_nl_lmf
      File: /Users/ruben/python_envs/python2.7/lib/python2.7/VUSentimentLexicon/NL-lexicon/Sentiment-Dutch-general.xml

Then you can use the lexicon identifiers to select the proper lexicon, with the
option --lexicon

    cat my_input.nl.kaf | polarity-tagger -- --lexicon general

This command will call to the polarity tagger using the general lexicon for
Dutch. The lexicon identifiers are unique only per language. If the lexicon id
is not specified (you skip the --lexicon option), or you provide a wrong
identifier, the default lexicon will be loaded. If there is no lexicon marked as
default in the --show-lexicon options, the first one in the list will be used.
Check the VU-sentiment-lexicon for further information about how to manage
lexicons and add new ones.

### Webservice

You can launch a webservice by executing:

    component-name-server

After launching the server, you can reach the webservice at
<http://localhost:9292>.

The webservice takes several options that get passed along to
[Puma](http://puma.io), the webserver used by the component. The options are:

        -h, --help                Shows this help message
            --puma-help           Shows the options of Puma
        -b, --bucket              The S3 bucket to store output in
            --authentication      An authentication endpoint to use
            --secret              Parameter name for the authentication secret
            --token               Parameter name for the authentication token
            --disable-syslog      Disables Syslog logging (enabled by default)

    Resource Options:

            --resource-url        URL pointing to a .zip/.tar.gz file to download
            --resource-path       Path where the resources should be saved

### Daemon

The daemon has the default OpeNER daemon options. Being:

    Usage: component-name-daemon <start|stop|restart> [options]

When calling component-name without `<start|stop|restart>` the daemon will start
as a foreground process.

Daemon options:

Options:

        -h, --help                Shows this help message
        -i, --input               The name of the input queue (default: opener-polarity-tagger)
        -b, --bucket              The S3 bucket to store output in (default: opener-polarity-tagger)
        -P, --pidfile             Path to the PID file (default: /var/run/opener/opener-polarity-tagger-daemon.pid)
        -t, --threads             The amount of threads to use (default: 10)
        -w, --wait                The amount of seconds to wait for the daemon to start (default: 3)
            --disable-syslog      Disables Syslog logging (enabled by default)

    Resource Options:

            --resource-url        URL pointing to a .zip/.tar.gz file to download
            --resource-path       Path where the resources should be saved

#### Environment Variables

These daemons make use of Amazon SQS queues and other Amazon services. For these
services to work correctly you'll need to have various environment variables
set. These are as following:

* `AWS_ACCESS_KEY_ID`
* `AWS_SECRET_ACCESS_KEY`
* `AWS_REGION`

For example:

    AWS_REGION='eu-west-1' language-identifier start [other options]

### Languages

* Dutch (nl)
* English (en)
* French (fr)
* German (de)
* Italian (it)
* Spanish (es)
