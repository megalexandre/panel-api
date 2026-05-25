Feature: Salvar Borderô

  Background:
    Given the time is frozen at "2026-08-01 00:00:00"
    Given I am authenticated as a user

  Scenario: Save bordero persists the bordero and returns it

    When I send a POST to "/bordero" with body:
      """
      {
        "change_date": "2026-08-01",
        "monthly_rate_percent": 2.5,
        "awaiting_days": 2,
        "receivables": [
          {"amount_cents": 100000, "due_date": "2026-08-27"},
          {"amount_cents": 100000, "due_date": "2026-09-02"},
          {"amount_cents": 100000, "due_date": "2026-09-03"}
        ]
      }
      """
    Then the response status should be 201
    And the response body should contain:
      """
      {
        "id": "@uuid",
        "change_date": "2026-08-01",
        "total_amount_cents": 300000,
        "total_proceeds_cents": 291500,
        "total_interest_amount_cents": 8500
      }
      """

  Scenario: Save bordero with a single receivable

    When I send a POST to "/bordero" with body:
      """
      {
        "change_date": "2026-08-01",
        "monthly_rate_percent": 2.5,
        "awaiting_days": 2,
        "receivables": [
          {"amount_cents": 100000, "due_date": "2026-08-27"}
        ]
      }
      """
    Then the response status should be 201
    And the response body should contain:
      """
      {
        "id": "@uuid",
        "change_date": "2026-08-01",
        "total_amount_cents": 100000,
        "total_proceeds_cents": 97500,
        "total_interest_amount_cents": 2500
      }
      """
