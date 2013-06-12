Feature: Using files as input and output
  In order to tag the polarity
  Using a file as an input
  Using a file as an output

  Scenario Outline: Tokenize the text
    Given the fixture file "<input_file>"
    And I put it through the kernel
    Then the output should match the fixture "<output_file>"
  Examples:
    | language | sentiment | input_file               | output_file                  |
    | French   | negative  | negative.tok.term.fr.kaf | negative.tok.term.pol.fr.kaf |
    | French   | positive  | positive.tok.term.fr.kaf | positive.tok.term.pol.fr.kaf |

