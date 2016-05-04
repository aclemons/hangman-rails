Feature: Home Page

  Scenario: Viewing the home page
    When I am on the home page
    Then I can create a new game

  Scenario: Viewing the home page
    When I am on the home page
    Then I can create a random game

  Scenario: Viewing the game list
    Given some games exist
    When I am on the home page
    Then I can view the list of games

  Scenario: Getting help
    When I am on the home page
    Then I can view the game help
