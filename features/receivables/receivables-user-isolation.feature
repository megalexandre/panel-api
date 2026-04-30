Feature: Receivables user isolation

  Background:
    Given I am authenticated as a user
    Given there is another user

  Scenario: User cannot see another user's receivables in the list

    Given the following receivables exist:
      | amount_cents | due_date   | status   |
      | 1000         | 2026-05-01 | awaiting |
    Given the following receivables exist for the other user:
      | amount_cents | due_date   | status   |
      | 9999         | 2026-05-01 | awaiting |
  
    When I send a GET to "/receivables"
    Then the response status should be 200

  Scenario: User cannot fetch another user's receivable by id
    Given the following receivables exist for the other user:
      | id                                   | amount_cents | due_date   | status   |
      | aabbccdd-0000-0000-0000-000000000001 | 9999         | 2026-05-01 | awaiting |
    When I send a GET to "/receivables/aabbccdd-0000-0000-0000-000000000001"
    Then the response status should be 404
