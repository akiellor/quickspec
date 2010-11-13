require 'rubygems'
require 'rake'
require 'git_change_set'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:quickspec) do |t|
  t.pattern = GitChangeSet.new(%x[pwd].chop).high_risk_specs
end
