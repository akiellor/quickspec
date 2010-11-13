require 'rubygems'
require 'quickspec/git_change_set'
require 'rake'
require 'rake/tasklib'
require 'spec/rake/spectask'

module QuickSpec
  class RakeTask < ::Rake::TaskLib
    def initialize name
      Spec::Rake::SpecTask.new(name) do |t|
        t.spec_files = FileList[GitChangeSet.new(%x[pwd].chop).high_risk_specs]
      end
    end
  end
end
