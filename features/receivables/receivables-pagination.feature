Feature: Receivables pagination and sorting

  Background:
    Given I am authenticated as a user

  Scenario: List receivables when there is no data
    When I send a GET to "/receivables"
    Then the response status should be 200
    And the response body should contain:
      """
      {
        "receivables": [],
        "pagination": {
          "current_page": 1,
          "per_page": 20,
          "total_pages": 0,
          "total_count": 0
        }
      }
      """

  Scenario: List receivables when there is data
    Given the following receivables exist:
      | amount_cents | due_date   | status   |
      | 1000         | 2026-05-01 | awaiting |
      | 2000         | 2026-06-01 | to_deposit |
      | 3000         | 2026-07-01 | overdue  |
    When I send a GET to "/receivables"
    Then the response status should be 200
    And the response should contain 3 receivables
    And the response body should contain:
      """
      {
        "pagination": {
          "current_page": 1,
          "per_page": 20,
          "total_pages": 1,
          "total_count": 3
        }
      }
      """

  Scenario Outline: Sort receivables by due_date
    Given the following receivables exist:
      | amount_cents | due_date   | status   |
      | 1000         | 2026-07-01 | awaiting |
      | 2000         | 2026-05-01 | awaiting |
      | 3000         | 2026-06-01 | awaiting |
    When I send a GET to "/receivables?sort_by=due_date&sort_direction=<direction>"
    Then the response status should be 200
    And the receivables should be ordered by "due_date" "<direction>"

    Examples:
      | direction |
      | asc       |
      | desc      |

  Scenario Outline: Sort receivables by amount
    Given the following receivables exist:
      | amount_cents | due_date   | status   |
      | 3000         | 2026-05-01 | awaiting |
      | 1000         | 2026-06-01 | awaiting |
      | 2000         | 2026-07-01 | awaiting |
    When I send a GET to "/receivables?sort_by=amount&sort_direction=<direction>"
    Then the response status should be 200
    And the receivables should be ordered by "amount_cents" "<direction>"

    Examples:
      | direction |
      | asc       |
      | desc      |
