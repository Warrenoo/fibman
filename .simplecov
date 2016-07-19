#!/usr/bin/env ruby
if ENV["COVERAGE"]
  SimpleCov.profiles.define 'fib' do
    add_filter "/vendor/"

    add_group 'Libraries', 'lib'
  end


  SimpleCov.start "request_pool" 
  puts "required simplecov"
end

# require 'request_pool'
