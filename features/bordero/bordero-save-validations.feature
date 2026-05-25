Feature: Salvar Borderô - Validações

  Background:
    Given the time is frozen at "2026-08-01 00:00:00"
    Given I am authenticated as a user

  Scenario: Save bordero without change_date

    When I send a POST to "/bordero" with body:
      """
      {
        "monthly_rate_percent": 2.5,
        "awaiting_days": 2,
        "receivables": [
          {"amount_cents": 100000, "due_date": "2026-08-27"}
        ]
      }
      """
    Then the response status should be 422
    And the response body should contain:
      """
      {
        "errors": {
          "change_date": ["can't be blank"]
        }
      }
      """

  Scenario: Save bordero without monthly_rate_percent

    When I send a POST to "/bordero" with body:
      """
      {
        "change_date": "2026-08-01",
        "awaiting_days": 2,
        "receivables": [
          {"amount_cents": 100000, "due_date": "2026-08-27"}
        ]
      }
      """
    Then the response status should be 422
    And the response body should contain:
      """
      {
        "errors": {
          "monthly_rate_percent": ["can't be blank", "is not a number"]
        }
      }
      """

  Scenario: Save bordero without receivables

    When I send a POST to "/bordero" with body:
      """
      {
        "change_date": "2026-08-01",
        "monthly_rate_percent": 2.5,
        "awaiting_days": 2
      }
      """
    Then the response status should be 422
    And the response body should contain:
      """
      {
        "errors": {
          "receivables": ["can't be blank"]
        }
      }
      """

  Scenario: Save bordero with empty receivables array

    When I send a POST to "/bordero" with body:
      """
      {
        "change_date": "2026-08-01",
        "monthly_rate_percent": 2.5,
        "awaiting_days": 2,
        "receivables": []
      }
      """
    Then the response status should be 422
    And the response body should contain:
      """
      {
        "errors": {
          "receivables": ["can't be blank"]
        }
      }
      """

  Scenario: Save bordero with invalid amount_cents in receivable

    When I send a POST to "/bordero" with body:
      """
      {
        "change_date": "2026-08-01",
        "monthly_rate_percent": 2.5,
        "awaiting_days": 2,
        "receivables": [
          {"amount_cents": 0, "due_date": "2026-08-27"}
        ]
      }
      """
    Then the response status should be 422
    And the response body should contain:
      """
      {
        "errors": {
          "receivables[0].amount_cents": ["must be a positive integer"]
        }
      }
      """

  Scenario: Save bordero with due_date before change_date

    When I send a POST to "/bordero" with body:
      """
      {
        "change_date": "2026-08-01",
        "monthly_rate_percent": 2.5,
        "awaiting_days": 2,
        "receivables": [
          {"amount_cents": 100000, "due_date": "2026-07-31"}
        ]
      }
      """
    Then the response status should be 422
    And the response body should contain:
      """
      {
        "errors": {
          "receivables[0].due_date": ["must be after change_date"]
        }
      }
      """

  Scenario: Save bordero with negative awaiting_days

    When I send a POST to "/bordero" with body:
      """
      {
        "change_date": "2026-08-01",
        "monthly_rate_percent": 2.5,
        "awaiting_days": -1,
        "receivables": [
          {"amount_cents": 100000, "due_date": "2026-08-27"}
        ]
      }
      """
    Then the response status should be 422
    And the response body should contain:
      """
      {
        "errors": {
          "awaiting_days": ["must be greater than or equal to 0"]
        }
      }
      """
