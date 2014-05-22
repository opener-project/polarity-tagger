Feature: Using files as input and output
  In order to tag the polarity
  Using a file as an input
  Using a file as an output

  Scenario Outline: Tokenize the text
    Given the fixture file "<input_file>"
    And I put it through the kernel
    Then the output should match the fixture "<output_file>"
  Examples:
    | language | input_file            | output_file            |
    | French   | input.fr.kaf          | output.fr.kaf          |
    | Dutch    | input.nl.kaf          | output.nl.kaf          | 
    | English  | input.en.kaf          | output.en.kaf          |
    | German   | input.de.kaf          | output.de.kaf          |
    | Spanish  | input.es.kaf          | output.es.kaf          |
    | Italian  | input.it.kaf          | output.it.kaf          |
