Feature: Receivables management

  Background:
    Given I am authenticated as a user
    Given the time is frozen at "2026-01-01 00:00:00"

  Scenario: Create a receivable

    When I send a POST to "/receivables" with body:
      """
      {
        "amount_cents": 10000,
        "due_date": "2026-03-01",
        "change_date": "2026-03-01",
        "status": "awaiting"
      }
      """
    Then the response status should be 201
    And the response body should contain:
      """
      {
        "id": "@uuid",
        "amount_cents": 10000,
        "due_date": "2026-03-01",
        "change_date": "2026-03-01",
        "awaiting_days": 59,
        "status": "awaiting",
        "created_at": "2026-01-01 00:00:00",
        "updated_at": "2026-01-01 00:00:00"
      }
      """


  Scenario Outline: Create a receivable with all statuses

    When I send a POST to "/receivables" with body:
      """
      {
        "amount_cents": 10000,
        "due_date": "2026-03-01",
        "change_date": "2026-03-01",
        "status": "awaiting"
      }
      """
    Then the response status should be 201
    And the response body should contain:
      """
      {
        "id": "@uuid",
        "amount_cents": 10000,
        "due_date": "2026-03-01",
        "change_date": "2026-03-01",
        "awaiting_days": 59,
        "status": "awaiting",
        "created_at": "2026-01-01 00:00:00",
        "updated_at": "2026-01-01 00:00:00"
      }
      """

    Examples:
      | status            |
      | awaiting          |
      | in_analysis       |
      | in_transaction    |
      | paid              |
      | overdue           |


