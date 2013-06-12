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
    | French   | fr_positive_input.kaf | fr_positive_output.kaf |
    | French   | fr_negative_input.kaf | fr_negative_output.kaf |
    | Dutch    | nl_positive_input.kaf | nl_positive_output.kaf |
    | Dutch    | nl_negative_input.kaf | nl_negative_output.kaf |
