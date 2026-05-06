Feature: Calendar index

  Background:
    Given I am authenticated as a user

  Scenario: Returns all days for May 2026
    When I send a GET to "/calendar?year=2026&month=5"
    Then the response status should be 200
    And the response body should contain:
      """
      {
        "year":  2026,
        "month": 5
      }
      """
    And the calendar response has 31 days

  Scenario: Saturday is flagged as weekend and not a business day
    When I send a GET to "/calendar?year=2026&month=5"
    Then the response status should be 200
    And the calendar day "2026-05-02" has weekend true and business_day false

  Scenario: Tiradentes is flagged as a holiday and not a business day
    When I send a GET to "/calendar?year=2026&month=4"
    Then the response status should be 200
    And the calendar day "2026-04-21" has holiday true and business_day false

  Scenario: Regular weekday is a business day
    When I send a GET to "/calendar?year=2026&month=5"
    Then the response status should be 200
    And the calendar day "2026-05-04" has business_day true

  Scenario: Returns 422 when year is missing
    When I send a GET to "/calendar?month=5"
    Then the response status should be 422

  Scenario: Returns 422 when month is out of range
    When I send a GET to "/calendar?year=2026&month=13"
    Then the response status should be 422

  Scenario: Returns 401 when not authenticated
    When I send a GET to "/calendar?year=2026&month=5" without auth
    Then the response status should be 401
