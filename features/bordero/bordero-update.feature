Feature: Atualizar Borderô

  Background:
    Given the time is frozen at "2026-08-01 00:00:00"
    Given I am authenticated as a user

  Scenario: Update bordero recalculates totals with inline receivables
    Given the following borderos exist:
      | id                                   | change_date | monthly_rate_percent | awaiting_days | total_amount_cents | total_proceeds_cents | total_interest_amount_cents | average_days |
      | aaaaaaaa-0000-0000-0000-000000000001 | 2026-07-01  | 1.0                  | 2             | 999999             | 888888               | 111111                      | 60.0         |

    When I send a PUT to "/bordero/aaaaaaaa-0000-0000-0000-000000000001" with body:
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
    Then the response status should be 200
    And the response body should contain:
      """
      {
        "id": "aaaaaaaa-0000-0000-0000-000000000001",
        "change_date": "2026-08-01",
        "monthly_rate_percent": 2.5,
        "awaiting_days": 2,
        "total_amount_cents": 100000,
        "total_proceeds_cents": 97500,
        "total_interest_amount_cents": 2500
      }
      """

  Scenario: Update bordero with multiple receivables via receivable_ids
    Given the following borderos exist:
      | id                                   | change_date | monthly_rate_percent | awaiting_days | total_amount_cents |
      | aaaaaaaa-0000-0000-0000-000000000002 | 2026-07-01  | 1.0                  | 2             | 999999             |
    And the following receivables exist:
      | id                                   | amount_cents | change_date | due_date   | status   |
      | bbbbbbbb-0000-0000-0000-000000000002 | 100000       | 2026-07-01  | 2026-08-27 | awaiting |
      | bbbbbbbb-0000-0000-0000-000000000003 | 100000       | 2026-07-01  | 2026-09-02 | awaiting |
      | bbbbbbbb-0000-0000-0000-000000000004 | 100000       | 2026-07-01  | 2026-09-03 | awaiting |

    When I send a PUT to "/bordero/aaaaaaaa-0000-0000-0000-000000000002" with body:
      """
      {
        "change_date": "2026-08-01",
        "monthly_rate_percent": 2.5,
        "awaiting_days": 2,
        "receivable_ids": [
          "bbbbbbbb-0000-0000-0000-000000000002",
          "bbbbbbbb-0000-0000-0000-000000000003",
          "bbbbbbbb-0000-0000-0000-000000000004"
        ]
      }
      """
    Then the response status should be 200
    And the response body should contain:
      """
      {
        "id": "aaaaaaaa-0000-0000-0000-000000000002",
        "change_date": "2026-08-01",
        "awaiting_days": 2,
        "total_amount_cents": 300000,
        "total_proceeds_cents": 291500,
        "total_interest_amount_cents": 8500
      }
      """

  Scenario: Returns 404 when bordero does not exist
    When I send a PUT to "/bordero/00000000-0000-0000-0000-000000000000" with body:
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
    Then the response status should be 404

  Scenario: Cannot update another user's bordero
    Given there is another user
    And the following borderos exist for the other user:
      | id                                   | change_date | monthly_rate_percent | awaiting_days | total_amount_cents |
      | aaaaaaaa-0000-0000-0000-000000000003 | 2026-07-01  | 1.0                  | 2             | 999999             |

    When I send a PUT to "/bordero/aaaaaaaa-0000-0000-0000-000000000003" with body:
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
    Then the response status should be 404
