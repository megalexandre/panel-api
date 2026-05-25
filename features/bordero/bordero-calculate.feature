Feature: Borderô — Calcular

  Background:
    Given the time is frozen at "2026-08-01 00:00:00"
    And I am authenticated as a user

  Scenario: 3 cheques com vencimentos em ago e set
    Given the bordero parameters:
      | change_date          | 2026-08-01 |
      | monthly_rate_percent | 2.5        |
      | awaiting_days        | 2          |
    And the receivables are:
      | amount_cents | due_date   |
      | 100000       | 2026-08-27 |
      | 100000       | 2026-09-02 |
      | 100000       | 2026-09-03 |
    When I calculate the bordero
    Then the response status should be 200
    And the bordero totals should be:
      | total_amount_cents          | 300000 |
      | total_proceeds_cents        | 291500 |
      | total_interest_amount_cents | 8500   |
      | average_days                | 34.0   |
    And the bordero items should be:
      | amount_cents | deposit_date | settlement_date | total_days | interest_rate_percent | interest_amount_cents | proceeds_cents |
      | 100000       | 2026-08-27   | 2026-08-31      | 30         | 2.5                   | 2500                  | 97500          |
      | 100000       | 2026-09-02   | 2026-09-04      | 34         | 2.8333                | 2833                  | 97167          |
      | 100000       | 2026-09-03   | 2026-09-08      | 38         | 3.1667                | 3167                  | 96833          |
