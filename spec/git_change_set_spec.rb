require "spec_helper"
require 'support/project'

describe GitChangeSet do
  context "an existing repository" do
    before :each do
      @test_repo_dir = '/tmp/work'
      @project = Project.new @test_repo_dir

      @project.clean
      @project.init
    end

    subject { GitChangeSet.new @test_repo_dir }

    context "no changes in repository" do
      it { should have(0).high_risk_specs }
    end

    context "repository with 5 untracked specs" do
      before :each do
        @project.make_specs "a", "b", "c", "d", "e"
      end

      it { should have(5).high_risk_specs }

      it { should have_high_risk_spec @project.spec "a" }
      it { should have_high_risk_spec @project.spec "b" }
      it { should have_high_risk_spec @project.spec "c" }
      it { should have_high_risk_spec @project.spec "d" }
      it { should have_high_risk_spec @project.spec "e" }
    end

    context "repository with 3 untracked specs and 2 untracked files" do
      before :each do
        @project.make_root "file_one.rb"
        @project.make_root "file_two.rb"
        @project.make_specs "a", "b", "c"
      end

      it { should have(3).high_risk_specs }

      it { should have_high_risk_spec @project.spec "a" }
      it { should have_high_risk_spec @project.spec "b" }
      it { should have_high_risk_spec @project.spec "c" }
      it { should_not have_high_risk_spec(@project.root "file_one.rb") }
      it { should_not have_high_risk_spec(@project.root "file_two.rb") }
    end

    context "repository with 2 changed specs" do
      before :each do
        @project.make_specs "a", "b", "c"
        @project.commit_all

        @project.change_spec "a"
        @project.change_spec "b"
      end

      it { should have(2).high_risk_specs }

      it { should have_high_risk_spec(@project.spec "a") }
      it { should have_high_risk_spec(@project.spec "b") }
    end

    context "repository with changed implementation file that has a spec" do
      before :each do
        @project.make_libs "a", "b"
        @project.make_specs "a", "b"
        @project.commit_all

        @project.change_lib 'b'
      end

      it { should have(1).high_risk_specs }

      it { should have_high_risk_spec(@project.spec "b") }
    end

    context "repository with changed implementation file that does not have a spec" do
      before :each do
        @project.make_specs "a", "b"
        @project.make @project.lib "c"
        @project.commit_all
        @project.change_lib 'c'
      end

      it { should have(0).high_risk_specs }
    end

    context "repository with changed implementation file and changed test for implementation" do
      before :each do
        @project.make_libs "a", "b"
        @project.make_specs "a", "b"
        @project.commit_all

        @project.change_lib "a"
        @project.change_spec "a"
      end

      it { should have(1).high_risk_specs }

      it { should have_high_risk_spec(@project.spec "a") }
    end
  end
end

Spec::Matchers.define :have_high_risk_spec do |expected_path|
  match { |change_set| change_set.high_risk_specs.include?(expected_path) }
end