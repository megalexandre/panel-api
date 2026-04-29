Feature: Receivables GET

  Background:
    Given I am authenticated as a user

  Scenario: get receivable by id

    Given the time is frozen at "2026-01-01 00:00:00"
    Given the following receivables exist:
      | id                                   | amount_cents | change_date | due_date   | status   |
      | 117b6176-c5c3-4b16-b8ad-8e8e2f4f9a14 | 1000         | 2026-01-01  | 2026-02-01 | awaiting |

    When I send a GET to "/receivables/117b6176-c5c3-4b16-b8ad-8e8e2f4f9a14"
    Then the response status should be 200
    And the response body should contain:
      """
      {
        "id": "117b6176-c5c3-4b16-b8ad-8e8e2f4f9a14",
        "amount_cents": 1000,
        "due_date": "2026-02-01",
        "change_date": "2026-01-01",
        "awaiting_days": 31,
        "status": "awaiting",
        "created_at": "2026-01-01 00:00:00",
        "deleted_at": null,
        "updated_at": "2026-01-01 00:00:00"
      }
      """

  Scenario Outline: get awaiting days for a receivable

    Given the time is frozen at "<frozen_date>"
    Given the following receivables exist:
      | id                                   | amount_cents | change_date   | due_date   | status   |
      | 117b6176-c5c3-4b16-b8ad-8e8e2f4f9a14 | 1000         | <frozen_date> | 2026-02-01 | awaiting |

    When I send a GET to "/receivables/117b6176-c5c3-4b16-b8ad-8e8e2f4f9a14"
    Then the response status should be 200
    And the response body should contain:
      """
      {
        "id": "117b6176-c5c3-4b16-b8ad-8e8e2f4f9a14",
        "amount_cents": 1000,
        "due_date": "2026-02-01",
        "change_date": "<change_date>",
        "awaiting_days": <awaiting_days>,
        "status": "awaiting"
      }
      """

    Examples:
      | frozen_date         | change_date | awaiting_days |
      | 2026-01-01 00:00:00 | 2026-01-01  | 31            |
      | 2026-01-02 00:00:00 | 2026-01-02  | 30            |
      | 2026-01-03 00:00:00 | 2026-01-03  | 29            |
      | 2026-01-04 00:00:00 | 2026-01-04  | 28            |
      | 2026-01-05 00:00:00 | 2026-01-05  | 27            |
      | 2026-01-06 00:00:00 | 2026-01-06  | 26            |
      | 2026-01-07 00:00:00 | 2026-01-07  | 25            |
      | 2026-01-08 00:00:00 | 2026-01-08  | 24            |
      | 2026-01-09 00:00:00 | 2026-01-09  | 23            |
      | 2026-01-10 00:00:00 | 2026-01-10  | 22            |
      | 2026-01-11 00:00:00 | 2026-01-11  | 21            |
      | 2026-01-12 00:00:00 | 2026-01-12  | 20            |
      | 2026-01-13 00:00:00 | 2026-01-13  | 19            |
      | 2026-01-14 00:00:00 | 2026-01-14  | 18            |
      | 2026-01-15 00:00:00 | 2026-01-15  | 17            |
      | 2026-01-16 00:00:00 | 2026-01-16  | 16            |
      | 2026-01-17 00:00:00 | 2026-01-17  | 15            |
      | 2026-01-18 00:00:00 | 2026-01-18  | 14            |
      | 2026-01-19 00:00:00 | 2026-01-19  | 13            |
      | 2026-01-20 00:00:00 | 2026-01-20  | 12            |
      | 2026-01-21 00:00:00 | 2026-01-21  | 11            |
      | 2026-01-22 00:00:00 | 2026-01-22  | 10            |
      | 2026-01-23 00:00:00 | 2026-01-23  | 9             |
      | 2026-01-24 00:00:00 | 2026-01-24  | 8             |
      | 2026-01-25 00:00:00 | 2026-01-25  | 7             |
      | 2026-01-26 00:00:00 | 2026-01-26  | 6             |
      | 2026-01-27 00:00:00 | 2026-01-27  | 5             |
      | 2026-01-28 00:00:00 | 2026-01-28  | 4             |
      | 2026-01-29 00:00:00 | 2026-01-29  | 3             |
      | 2026-01-30 00:00:00 | 2026-01-30  | 2             |
      | 2026-01-31 00:00:00 | 2026-01-31  | 1             |