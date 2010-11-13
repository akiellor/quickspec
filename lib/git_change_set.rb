require 'grit'

class GitChangeSet
  include Grit

  def initialize repo_dir
    @repo = Grit::Repo.init(repo_dir)
  end

  def high_risk_specs
    @repo.status.untracked.collect {|k, v| @repo.working_dir + "/" + k}.select {|f| f.end_with? "_spec.rb"} 
  end
end