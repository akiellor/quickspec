require 'grit'

class GitChangeSet
  include Grit

  def initialize repo_dir
    @repo = Grit::Repo.init(repo_dir)
  end

  def high_risk_specs
    untracked_specs + changed_specs + specs_with_changed_implementation
  end

  private
  def specs_with_changed_implementation
    @repo.status.changed.select {|k, v| k.start_with? "lib"}.collect{|f, v| @repo.working_dir + "/" + f.sub(/^lib/, "spec").sub(/.rb$/, "_spec.rb")}.select{|f| File.exist? f}
  end

  def changed_specs
    @repo.status.changed.collect {|k, v| @repo.working_dir + "/" + k}.select {|f| f.end_with? "_spec.rb"}
  end

  def untracked_specs
    @repo.status.untracked.collect {|k, v| @repo.working_dir + "/" + k}.select {|f| f.end_with? "_spec.rb"}
  end
end