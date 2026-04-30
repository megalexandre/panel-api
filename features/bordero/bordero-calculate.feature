Feature: Borderô calculation

  # Using receivables with exact round numbers for deterministic assertions:
  # 30 days at 2.5%/month  → rate = 2.5%   exactly (1.025^1 - 1)
  # 60 days at 2.5%/month  → rate = 5.0625% exactly (1.025^2 - 1)

  Background:
    Given I am authenticated as a user

  Scenario: Calculate with one receivable
    When I send a POST to "/bordero/calculate" with body:
      """
      {
        "change_date": "2026-05-02",
        "monthly_rate_percent": 2.5,
        "receivables": [
          {"amount_cents": 100000, "due_date": "2026-06-01", "awaiting_days": 0}
        ]
      }
      """
    Then the response status should be 200
    And the response body should contain:
      """
      {
        "total_amount_cents": 100000,
        "average_days": 30.0,
        "items": [
          {
            "amount_cents": 100000,
            "due_date": "2026-06-01",
            "total_days": 30,
            "interest_rate_percent": 2.5,
            "interest_amount_cents": 2500,
            "proceeds_cents": 97500
          }
        ]
      }
      """

  Scenario: Calculate with two receivables
    When I send a POST to "/bordero/calculate" with body:
      """
      {
        "change_date": "2026-05-02",
        "monthly_rate_percent": 2.5,
        "receivables": [
          {"amount_cents": 100000, "due_date": "2026-06-01", "awaiting_days": 0},
          {"amount_cents": 100000, "due_date": "2026-07-01", "awaiting_days": 0}
        ]
      }
      """
    Then the response status should be 200
    And the response body should contain:
      """
      {
        "total_amount_cents": 200000,
        "average_days": 45.0,
        "items": [
          {
            "amount_cents": 100000,
            "due_date": "2026-06-01",
            "total_days": 30,
            "interest_rate_percent": 2.5,
            "interest_amount_cents": 2500,
            "proceeds_cents": 97500
          },
          {
            "amount_cents": 100000,
            "due_date": "2026-07-01",
            "total_days": 60,
            "interest_rate_percent": 5.0625,
            "interest_amount_cents": 5063,
            "proceeds_cents": 94937
          }
        ]
      }
      """

  Scenario: Calculate respects awaiting_days
    When I send a POST to "/bordero/calculate" with body:
      """
      {
        "change_date": "2026-05-02",
        "monthly_rate_percent": 2.5,
        "receivables": [
          {"amount_cents": 100000, "due_date": "2026-06-04", "awaiting_days": 3}
        ]
      }
      """
    Then the response status should be 200
    And the response body should contain:
      """
      {
        "total_amount_cents": 100000,
        "average_days": 30.0,
        "items": [
          {
            "amount_cents": 100000,
            "due_date": "2026-06-04",
            "total_days": 30,
            "interest_rate_percent": 2.5,
            "interest_amount_cents": 2500,
            "proceeds_cents": 97500
          }
        ]
      }
      """

  Scenario: Returns 422 when receivables is empty
    When I send a POST to "/bordero/calculate" with body:
      """
      {
        "change_date": "2026-05-02",
        "monthly_rate_percent": 2.5,
        "receivables": []
      }
      """
    Then the response status should be 422

  Scenario: Returns 422 when monthly_rate_percent is negative
    When I send a POST to "/bordero/calculate" with body:
      """
      {
        "change_date": "2026-05-02",
        "monthly_rate_percent": -1.0,
        "receivables": [
          {"amount_cents": 100000, "due_date": "2026-06-01", "awaiting_days": 0}
        ]
      }
      """
    Then the response status should be 422

  Scenario: Returns 422 when due_date is not after change_date + awaiting_days
    When I send a POST to "/bordero/calculate" with body:
      """
      {
        "change_date": "2026-05-02",
        "monthly_rate_percent": 2.5,
        "receivables": [
          {"amount_cents": 100000, "due_date": "2026-05-02", "awaiting_days": 0}
        ]
      }
      """
    Then the response status should be 422
``