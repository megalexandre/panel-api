Feature: Borderô

  Background:
    Given the time is frozen at "2026-08-01 00:00:00"
    Given I am authenticated as a user

  Scenario: Calculate with one receivable

    When I send a POST to "/bordero/calculate" with body:
      """
      {
        "change_date": "2026-08-01",
        "monthly_rate_percent": 2.5,
        "receivables": [
          {"amount_cents": 100000, "due_date": "2026-08-27", "awaiting_days": 2},
          {"amount_cents": 100000, "due_date": "2026-09-02", "awaiting_days": 2},
          {"amount_cents": 100000, "due_date": "2026-09-03", "awaiting_days": 2}
        ]
      }
      """
    Then the response status should be 200
    And the response body should contain:
      """
      {
        "total_amount_cents": 300000,
        "total_proceeds_cents": 291485,
        "total_interest_amount_cents": 8515,
        "average_days": 34.0,
        "items": [
          {
            "amount_cents": 100000,
            "deposit_date": "2026-08-27",
            "settlement_date": "2026-08-31",
            "total_days": 30,
            "interest_rate_percent": 2.5,
            "interest_amount_cents": 2500,
            "proceeds_cents": 97500
          },
          {
            "amount_cents": 100000,
            "deposit_date": "2026-09-02",
            "settlement_date": "2026-09-04",
            "total_days": 34,
            "interest_rate_percent": 2.838,
            "interest_amount_cents": 2838,
            "proceeds_cents": 97162
          },
          {
            "amount_cents": 100000,
            "deposit_date": "2026-09-03",
            "settlement_date": "2026-09-08",
            "total_days": 38,
            "interest_rate_percent": 3.1772,
            "interest_amount_cents": 3177,
            "proceeds_cents": 96823
          }
        ]
      }
      """
