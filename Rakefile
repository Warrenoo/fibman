#!/usr/bin/env rake

begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks.'
end

# === Bundler ===

Bundler::GemHelper.install_tasks

# === RSpec ===

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new :spec

# === RuboCop ===

require 'rubocop/rake_task'

RuboCop::RakeTask.new(:rubocop) do |task|
  task.requires << 'rubocop-rspec'

  # Don't abort Rake on failure.
  task.fail_on_error = false
end

# === Configuration ===

# Run all specs and RuboCop as default task.
task default: [:spec, :rubocop]

task test: [:spec, :rubocop]
