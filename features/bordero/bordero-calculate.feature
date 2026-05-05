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

  Scenario: due_date em sábado é ajustado para segunda na contagem de dias
    When I send a POST to "/bordero/calculate" with body:
      """
      {
        "change_date": "2026-05-11",
        "monthly_rate_percent": 2.5,
        "receivables": [
          {"amount_cents": 100000, "due_date": "2026-06-13", "awaiting_days": 0}
        ]
      }
      """
    Then the response status should be 200
    And the response body should contain:
      """
      {
        "total_amount_cents": 100000,
        "average_days": 35.0,
        "items": [
          {
            "amount_cents": 100000,
            "due_date": "2026-06-13",
            "total_days": 35,
            "interest_rate_percent": 2.9227,
            "interest_amount_cents": 2923,
            "proceeds_cents": 97077
          }
        ]
      }
      """

  Scenario: due_date em domingo é ajustado para segunda na contagem de dias
    When I send a POST to "/bordero/calculate" with body:
      """
      {
        "change_date": "2026-05-11",
        "monthly_rate_percent": 2.5,
        "receivables": [
          {"amount_cents": 100000, "due_date": "2026-06-14", "awaiting_days": 0}
        ]
      }
      """
    Then the response status should be 200
    And the response body should contain:
      """
      {
        "total_amount_cents": 100000,
        "average_days": 35.0,
        "items": [
          {
            "amount_cents": 100000,
            "due_date": "2026-06-14",
            "total_days": 35,
            "interest_rate_percent": 2.9227,
            "interest_amount_cents": 2923,
            "proceeds_cents": 97077
          }
        ]
      }
      """

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