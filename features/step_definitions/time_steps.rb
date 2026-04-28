Given("the time is frozen at {string}") do |time|
  Timecop.freeze(Time.parse(time))
end

Given("the time is traveling from {string}") do |time|
  Timecop.travel(Time.parse(time))
end

After do
  Timecop.return
end
