Feature: Borderô — Calcular com dados reais

  Background:
    Given the time is frozen at "2026-05-20 00:00:00"
    Given I am authenticated as a user

  Scenario: Cheque 3 — R$ 3.133,33 vencimento 19/07

    When I send a POST to "/bordero/calculate" with body:
      """
      {
        "change_date": "2026-05-20",
        "monthly_rate_percent": 4.0,
        "receivables": [
          {
            "amount_cents": 313333, 
            "due_date": "2026-07-19", 
            "awaiting_days": 2
          }
        ]
      }
      """
    Then the response status should be 200
    And the response body should contain:
      """
      {
        "total_amount_cents": 313333,
        "total_proceeds_cents": 287431,
        "total_interest_amount_cents": 25902,

        "average_days": 62.0,

        "items": [
          {
            "amount_cents": 313333,
            "deposit_date": "2026-07-20",
            "settlement_date": "2026-07-22",
            "total_days": 62,
            "interest_rate_percent": 8.2667,
            "interest_amount_cents": 25902,
            "proceeds_cents": 287431
          }
        ]
      }
      """
