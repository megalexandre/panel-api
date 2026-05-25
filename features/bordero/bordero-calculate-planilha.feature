Feature: Borderô — Calcular com dados da planilha (6 cheques)

  Background:
    Given the time is frozen at "2026-05-20 00:00:00"
    And I am authenticated as a user

  Scenario: 6 cheques com vencimentos distribuídos em jun, jul e ago
    Given the bordero parameters:
      | change_date          | 2026-05-20 |
      | monthly_rate_percent | 4.0        |
      | awaiting_days        | 2          |
    And the receivables are:
      | amount_cents | due_date   |
      | 386666       | 2026-06-19 |
      | 240000       | 2026-06-19 |
      | 313333       | 2026-07-19 |
      | 313333       | 2026-07-19 |
      | 313333       | 2026-08-19 |
      | 313333       | 2026-08-19 |
    When I calculate the bordero
    Then the response status should be 200
    And the bordero totals should be:
      | total_amount_cents          | 1879998 |
      | total_proceeds_cents        | 1722079 |
      | total_interest_amount_cents | 157919  |
      | average_days                | 63.0    |
    And the bordero items should be:
      | amount_cents | deposit_date | settlement_date | total_days | interest_rate_percent | interest_amount_cents | proceeds_cents |
      | 386666       | 2026-06-19   | 2026-06-23      | 34         | 4.5333                | 17529                 | 369137         |
      | 240000       | 2026-06-19   | 2026-06-23      | 34         | 4.5333                | 10880                 | 229120         |
      | 313333       | 2026-07-20   | 2026-07-22      | 62         | 8.2667                | 25902                 | 287431         |
      | 313333       | 2026-07-20   | 2026-07-22      | 62         | 8.2667                | 25902                 | 287431         |
      | 313333       | 2026-08-19   | 2026-08-21      | 93         | 12.4                  | 38853                 | 274480         |
      | 313333       | 2026-08-19   | 2026-08-21      | 93         | 12.4                  | 38853                 | 274480         |
