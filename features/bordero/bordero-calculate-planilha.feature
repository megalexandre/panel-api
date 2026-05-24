Feature: Borderô — Calcular com dados da planilha (6 cheques)

  Background:
    Given the time is frozen at "2026-05-20 00:00:00"
    Given I am authenticated as a user

  Scenario: 6 cheques com vencimentos em jun/jul/ago — dados reais da planilha

    When I send a POST to "/bordero/calculate" with body:
      """
      {
        "change_date": "2026-05-20",
        "monthly_rate_percent": 4.0,
        "receivables": [
          { "amount_cents": 386666, "due_date": "2026-06-19", "awaiting_days": 2 },
          { "amount_cents": 240000, "due_date": "2026-06-19", "awaiting_days": 2 },
          { "amount_cents": 313333, "due_date": "2026-07-19", "awaiting_days": 2 },
          { "amount_cents": 313333, "due_date": "2026-07-19", "awaiting_days": 2 },
          { "amount_cents": 313333, "due_date": "2026-08-19", "awaiting_days": 2 },
          { "amount_cents": 313333, "due_date": "2026-08-19", "awaiting_days": 2 }
        ]
      }
      """
    Then the response status should be 200
    And the response body should contain:
      """
      {
        "total_amount_cents": 1879998,
        "total_proceeds_cents": 1722079,
        "total_interest_amount_cents": 157919,
        "average_days": 63.0,

        "items": [
          {
            "amount_cents": 386666,
            "deposit_date": "2026-06-19",
            "settlement_date": "2026-06-23",
            "total_days": 34,
            "interest_rate_percent": 4.5333,
            "interest_amount_cents": 17529,
            "proceeds_cents": 369137
          },
          {
            "amount_cents": 240000,
            "deposit_date": "2026-06-19",
            "settlement_date": "2026-06-23",
            "total_days": 34,
            "interest_rate_percent": 4.5333,
            "interest_amount_cents": 10880,
            "proceeds_cents": 229120
          },
          {
            "amount_cents": 313333,
            "deposit_date": "2026-07-20",
            "settlement_date": "2026-07-22",
            "total_days": 62,
            "interest_rate_percent": 8.2667,
            "interest_amount_cents": 25902,
            "proceeds_cents": 287431
          },
          {
            "amount_cents": 313333,
            "deposit_date": "2026-07-20",
            "settlement_date": "2026-07-22",
            "total_days": 62,
            "interest_rate_percent": 8.2667,
            "interest_amount_cents": 25902,
            "proceeds_cents": 287431
          },
          {
            "amount_cents": 313333,
            "deposit_date": "2026-08-19",
            "settlement_date": "2026-08-21",
            "total_days": 93,
            "interest_rate_percent": 12.4,
            "interest_amount_cents": 38853,
            "proceeds_cents": 274480
          },
          {
            "amount_cents": 313333,
            "deposit_date": "2026-08-19",
            "settlement_date": "2026-08-21",
            "total_days": 93,
            "interest_rate_percent": 12.4,
            "interest_amount_cents": 38853,
            "proceeds_cents": 274480
          }
        ]
      }
      """
