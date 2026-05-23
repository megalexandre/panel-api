Feature: Listar Borderôs com paginação

  Background:
    Given I am authenticated as a user

  Scenario: List borderos when there is no data
    When I send a GET to "/bordero"
    Then the response status should be 200
    And the response body should contain:
      """
      {
        "items": [],
        "pagination": {
          "current_page": 1,
          "per_page": 20,
          "total_pages": 0,
          "total_count": 0
        },
        "summary": {
          "count": 0,
          "total_amount_cents": 0,
          "total_proceeds_cents": 0,
          "total_interest_amount_cents": 0
        }
      }
      """

  Scenario: List borderos when there is data
    Given the following borderos exist:
      | change_date | total_amount_cents | total_proceeds_cents | total_interest_amount_cents | average_days |
      | 2026-07-01  | 100000             | 97500                | 2500                        | 30.0         |
      | 2026-08-01  | 200000             | 195000               | 5000                        | 35.0         |
      | 2026-09-01  | 300000             | 292500               | 7500                        | 40.0         |
    When I send a GET to "/bordero"
    Then the response status should be 200
    And the response should contain 3 borderos
    And the response body should contain:
      """
      {
        "pagination": {
          "current_page": 1,
          "per_page": 20,
          "total_pages": 1,
          "total_count": 3
        },
        "summary": {
          "count": 3,
          "total_amount_cents": 600000,
          "total_proceeds_cents": 585000,
          "total_interest_amount_cents": 15000
        }
      }
      """

  Scenario: List borderos with pagination
    Given the following borderos exist:
      | change_date | total_amount_cents |
      | 2026-07-01  | 100000             |
      | 2026-08-01  | 200000             |
      | 2026-09-01  | 300000             |
    When I send a GET to "/bordero?page=2&per_page=2"
    Then the response status should be 200
    And the response should contain 1 bordero
    And the response body should contain:
      """
      {
        "pagination": {
          "current_page": 2,
          "per_page": 2,
          "total_pages": 2,
          "total_count": 3
        }
      }
      """

  Scenario Outline: Sort borderos by change_date
    Given the following borderos exist:
      | change_date | total_amount_cents |
      | 2026-09-01  | 100000             |
      | 2026-07-01  | 200000             |
      | 2026-08-01  | 300000             |
    When I send a GET to "/bordero?sort_by=change_date&sort_direction=<direction>"
    Then the response status should be 200
    And the borderos should be ordered by "change_date" "<direction>"

    Examples:
      | direction |
      | asc       |
      | desc      |

  Scenario Outline: Sort borderos by total_amount_cents
    Given the following borderos exist:
      | change_date | total_amount_cents |
      | 2026-07-01  | 300000             |
      | 2026-08-01  | 100000             |
      | 2026-09-01  | 200000             |
    When I send a GET to "/bordero?sort_by=total_amount_cents&sort_direction=<direction>"
    Then the response status should be 200
    And the borderos should be ordered by "total_amount_cents" "<direction>"

    Examples:
      | direction |
      | asc       |
      | desc      |
