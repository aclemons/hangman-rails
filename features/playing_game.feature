Feature: Playing the game

  Scenario: Guessing a letter
    Given I have started a game
    When I guess a correct letter
    Then I see the letter as part of the word
    And I see the letter in the list of used letters
    And I have lost no lives

  Scenario: Guessing an incorrect letter
    Given I have started a game
    When I guess an incorrect letter
    Then I do not see the letter as part of the word
    And I see the incorrect letter in the list of used letters
    And I have lost one life

  Scenario: Guessing a duplicate letter
    Given I have started a game
    When I guess a duplicate letter
    Then I am notified that the letter has already been used

  Scenario: Guessing a non-letter
    Given I have started a game
    When I guess a non-letter
    Then I am notified that the guess must be a letter

  Scenario: Losing the game
    Given I have started a game
    When I guess an incorrect letter with one life left
    Then I am notified that the game is over
    And I see the word I was trying to guess

  Scenario: Winning the game
    Given I have started a game
    When I guess correctly the last missing letter
    Then I am notified that the game was won
    And I see the word I was trying to guess
