## Reference

#### Examples:

##### Simple polarity tagging

```
cat some-kaf-file.kaf | polarity-tagger
```

Partial output
```
<term lemma="donner" morphofeat="VP3s" pos="V" tid="t119" type="open">
  <span>
    <!--donne-->
    <target id="w119"/>
  </span>
  <sentiment polarity="neutral" resource="General domain lexicon for French . Vicomtech_general_lexicon_french"/>
</term>
```

#### Switching to another lexicon

```
cat some-kaf-file.kaf | polarity-tagger --resource-path path/to/lexicon
```

#### Downloading and switching to lexicon

```
cat some-kaf-file.kaf | polarity-tagger --resource_path path/to/extract/lexicon \
  --resource-url http://some.kind.of/zip-file.zip
```

#### Disabling pos matching

To push options to the python core use a double dash (--)

```
cat some-kaf.kaf | polarity -- --no-pos
```

#### Getting to the core

The main script of this tool is a python file, which accepts a set of parameters to determine which features
or options we want to use. The language is read from the KAF file, so it doesn't need to be specified as a parameter.
The program reads a KAF file from the standard input and writes the resulting KAf in the standard output.
To see the options you can call to the main script with the -h or --help option
````shell
polarity-tagger -- -h
usage: poltagger-basic-multi.py [-h] [--no-time] [--ignore-pos]
                                [--show-lexicons {nl,en,de,es,it,fr}]
                                [--lexicon LEXICON] [--silent] [--version]

Tags a text with polarities at lemma level

optional arguments:
  -h, --help            show this help message and exit
  --no-time             For not including timestamp in header
  --ignore-pos          Ignore the pos labels
  --show-lexicons {nl,en,de,es,it,fr}
                        Show lexicons for the given language and exit
  --lexicon LEXICON     Lexicon identifier, check with --show-lexicons LANG
                        for options
  --silent              Turn off debug info
  --version             show program's version number and exit
````

The `--ignore-pos` parameter must be used when want to ignore the part-of-speech information assigned to the lemmas, and we want to assign polarities
just to the lemmas, not considering the POS tag. This could be useful when the information provided by the pos-tagger is not accurate or the pos-tagging
has not been processed.

The main options are those concerning with the usage of different lexicons. The lexicons are provided by the
VU-sentiment-lexicon library (https://github.com/opener-project/VU-sentiment-lexicon), which needs to be installed.
You can see what the lexicons available for a given language are by calling to the program with the option --show-lexicons LANG,
for instance:
````shell
polarity-tagger -- --show-lexicons nl

##############################
Available lexicons for nl
  Identifier: "hotel" (Default)
    Desc: Hotel domain lexicon for Dutch
     Res: VUA_olery_lexicon_nl_lmf
    File: /Users/ruben/python_envs/python2.7/lib/python2.7/VUSentimentLexicon/NL-lexicon/Sentiment-Dutch-HotelDomain.xml

  Identifier:"general"
    Desc: General lexicon for Dutch
     Res: VUA_olery_lexicon_nl_lmf
    File: /Users/ruben/python_envs/python2.7/lib/python2.7/VUSentimentLexicon/NL-lexicon/Sentiment-Dutch-general.xml

##############################
````

Then you can use the lexicon identifiers to select the proper lexicon, with the option --lexicon
````shell
cat my_input.nl.kaf | polarity-tagger -- --lexicon general
````

This command will call to the polarity tagger using the general lexicon for Dutch. The lexicon identifiers are unique only per language.
If the lexicon id is not specified(you skip the --lexicon option), or you provide a wrong identifier, the default lexicon will be loaded.
If there is no lexicon marked as default in the --show-lexicon options, the first one in the list will be used. Check the VU-sentiment-lexicon
for further information about how to manage lexicons and add new ones

### Webservice

You can launch a webservice by executing:

```
component-name-server
```

After launching the server, you can reach the webservice at
<http://localhost:9292>.

The webservice takes several options that get passed along to (Puma)[http://puma.io], the
webserver used by the component. The options are:

```
    -b, --bind URI                   URI to bind to (tcp://, unix://, ssl://)
    -C, --config PATH                Load PATH as a config file
        --control URL                The bind url to use for the control server
                                     Use 'auto' to use temp unix server
        --control-token TOKEN        The token to use as authentication for the control server
    -d, --daemon                     Daemonize the server into the background
        --debug                      Log lowlevel debugging information
        --dir DIR                    Change to DIR before starting
    -e, --environment ENVIRONMENT    The environment to run the Rack app on (default development)
    -I, --include PATH               Specify $LOAD_PATH directories
    -p, --port PORT                  Define the TCP port to bind to
                                     Use -b for more advanced options
        --pidfile PATH               Use PATH as a pidfile
        --preload                    Preload the app. Cluster mode only
        --prune-bundler              Prune out the bundler env if possible
    -q, --quiet                      Quiet down the output
    -R, --restart-cmd CMD            The puma command to run during a hot restart
                                     Default: inferred
    -S, --state PATH                 Where to store the state details
    -t, --threads INT                min:max threads to use (default 0:16)
        --tcp-mode                   Run the app in raw TCP mode instead of HTTP mode
    -V, --version                    Print the version information
    -w, --workers COUNT              Activate cluster mode: How many worker processes to create
        --tag NAME                   Additional text to display in process listing
    -h, --help                       Show help
```


### Daemon

The daemon has the default OpeNER daemon options. Being:

```
Usage: component-name-daemon <start|stop|restart> [options]

When calling component-name without <start|stop|restart> the daemon will start as a foreground process

Daemon options:
    -i, --input QUEUE_NAME           Input queue name
    -o, --output QUEUE_NAME          Output queue name
        --batch-size COUNT           Request x messages at once where x is between 1 and 10
        --buffer-size COUNT          Size of input and output buffer. Defaults to 4 * batch-size
        --sleep-interval SECONDS     The interval to sleep when the queue is empty (seconds)
    -r, --readers COUNT              number of reader threads
    -w, --workers COUNT              number of worker thread
    -p, --writers COUNT              number of writer / pusher threads
    -l, --logfile, --log FILENAME    Filename and path of logfile. Defaults to STDOUT
    -P, --pidfile, --pid FILENAME    Filename and path of pidfile. Defaults to /var/run/tokenizer.pid
        --pidpath DIRNAME            Directory where to put the PID file. Is Overwritten by --pid if that option is present
        --debug                      Turn on debug log level
        --relentless                 Be relentless, fail fast, fail hard, do not continue processing when encountering component errors
```

#### Environment Variables

These daemons make use of Amazon SQS queues and other Amazon services.
The access to these services and other environment variables can be configured
using a .opener-daemons-env file in the home directory of the current user.

It is also possible to provide the environment variables directly to the deamon.

For example:

```
AWS_REGION='eu-west-1' component-name start [other options]
```

We advise to have the following environment variables available:

* AWS_ACCESS_KEY_ID
* AWS_SECRET_ACCESS_KEY
* AWS_REGION

### Languages

* Dutch (nl)
* English (en)
* French (fr)
* German (de)
* Italian (it)
* Spanish (es)

