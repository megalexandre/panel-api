# frozen_string_literal: true

When("I send a {word} to {string} without auth") do |method, path|
  send(method.downcase, path, {}, {})
end

Then("the calendar response has {int} days") do |count|
  expect(JSON.parse(last_response.body)["days"].size).to eq(count)
end

Then("the calendar day {string} has weekend {word} and business_day {word}") do |date, weekend, business_day|
  day = find_calendar_day(date)
  expect(day["weekend"]).to eq(weekend == "true")
  expect(day["business_day"]).to eq(business_day == "true")
end

Then("the calendar day {string} has holiday {word} and business_day {word}") do |date, holiday, business_day|
  day = find_calendar_day(date)
  expect(day["holiday"]).to eq(holiday == "true")
  expect(day["business_day"]).to eq(business_day == "true")
end

Then("the calendar day {string} has business_day {word}") do |date, business_day|
  day = find_calendar_day(date)
  expect(day["business_day"]).to eq(business_day == "true")
end

def find_calendar_day(date)
  days = JSON.parse(last_response.body)["days"]
  day  = days.find { |d| d["date"] == date }
  expect(day).not_to be_nil, "No day found for #{date} in response"
  day
end
