begin
  require "rubygems"
  require "bundler"
rescue LoadError
  raise "Could not load the bundler gem. Install it with `gem install bundler`."
end

begin
  ENV["BUNDLE_GEMFILE"] = File.expand_path("../../Gemfile", __FILE__)
  Bundler.setup
rescue Bundler::GemNotFound => e
  raise RuntimeError, "Bundler couldn't find some gems." +
          "Did you run `bundle install`? (#{e.message})"
end

require 'pp'

Dir["#{File.dirname(__FILE__)}/../lib/**/*.rb"].each { |file| require file }
