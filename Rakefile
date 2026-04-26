# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require "shellwords"

# Re-exec under Bundler to avoid activating a mismatched global rake version.
if ENV["BUNDLE_BIN_PATH"].nil?
	exec("bundle", "exec", "rake", *ARGV)
end

require_relative "config/application"

Rails.application.load_tasks
