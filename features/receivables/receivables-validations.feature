Feature: Receivables management

  Background:
    Given I am authenticated as a user
    Given the time is frozen at "2026-01-01 00:00:00"


  Scenario: Create a receivable without amount_cents

    When I send a POST to "/receivables" with body:
      """
      {
        "due_date": "2026-03-01",
        "change_date": "2026-03-01",
        "status": "awaiting"
      }
      """
    Then the response status should be 422
    And the response body should contain:
      """
       {
        "errors": [
          "Amount cents can't be blank"
        ]
      }
      """


  Scenario: Create a receivable without due_date

    When I send a POST to "/receivables" with body:
      """
      {
        "amount_cents": 10000,
        "change_date": "2026-03-01",
        "status": "awaiting"
      }
      """
    Then the response status should be 422


  Scenario: Create a receivable without status

    When I send a POST to "/receivables" with body:
      """
      {
        "amount_cents": 10000,
        "due_date": "2026-03-01",
        "change_date": "2026-03-01"
      }
      """
    Then the response status should be 422


  Scenario: Create a receivable without change_date

    When I send a POST to "/receivables" with body:
      """
      {
        "amount_cents": 10000,
        "due_date": "2026-03-01",
        "status": "awaiting"
      }
      """
    Then the response status should be 422


  Scenario: Create a receivable with wrong values in status

    When I send a POST to "/receivables" with body:
      """
      {
        "amount_cents": 10000,
        "due_date": "2026-03-01",
        "change_date": "2026-03-01",
        "status": "invalid_status"
      }
      """
    Then the response status should be 422
    And the response body should contain:
      """
      {
        "errors": [
          "Status is not included in the list"
        ]
      }
      """