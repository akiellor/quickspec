require "spec_helper"
require 'grit'

describe GitChangeSet do

  context "an existing repository" do
    before :each do
      @work_dir = Rspec.configuration.work_dir
      %x[rm -Rf #{@work_dir}]
      @test_repo_dir = "#{@work_dir}/test-repo"
      %x[mkdir #{@work_dir}]
      %x[mkdir #{@test_repo_dir}]
      %x[touch #{@test_repo_dir}/README]
      %x[cd #{@test_repo_dir}]

      %x[git init #{@test_repo_dir}]
      %x[git --git-dir=#{@test_repo_dir}/.git --work-tree=#{@test_repo_dir} add .]
      %x[git --git-dir=#{@test_repo_dir}/.git --work-tree=#{@test_repo_dir} commit -m 'Initial commit.']
    end

    subject { GitChangeSet.new @test_repo_dir }

    context "no changes in repository" do
      it { should have(0).high_risk_specs }
    end

    context "repository with 5 untracked specs" do
      before :each do
        %x[mkdir #{@test_repo_dir}/spec]
        %w{  a b c d e  }.each do |letter|
          %x[touch #{@test_repo_dir}/spec/#{letter}_spec.rb]
        end
      end
      
      it { should have(5).high_risk_specs }

      it { should have_high_risk_spec(@test_repo_dir + "/spec/a_spec.rb") }
      it { should have_high_risk_spec(@test_repo_dir + "/spec/b_spec.rb") }
      it { should have_high_risk_spec(@test_repo_dir + "/spec/c_spec.rb") }
      it { should have_high_risk_spec(@test_repo_dir + "/spec/d_spec.rb") }
      it { should have_high_risk_spec(@test_repo_dir + "/spec/e_spec.rb") }
    end

    context "repository with 3 untracked specs and 2 untracked files" do
      before :each do
        %x[touch #{@test_repo_dir}/file_one.rb]
        %x[touch #{@test_repo_dir}/file_two.rb]
        %x[mkdir #{@test_repo_dir}/spec]
        %w{ a b c }.each do |letter|
          %x[touch #{@test_repo_dir}/spec/#{letter}_spec.rb]
        end
      end

      it { should have(3).high_risk_specs }

      it { should have_high_risk_spec(@test_repo_dir + "/spec/a_spec.rb") }
      it { should have_high_risk_spec(@test_repo_dir + "/spec/b_spec.rb") }
      it { should have_high_risk_spec(@test_repo_dir + "/spec/c_spec.rb") }
      it { should_not have_high_risk_spec(@test_repo_dir + "/file_one.rb") }
      it { should_not have_high_risk_spec(@test_repo_dir + "/file_two.rb") }
    end

    context "repository with 2 changed specs" do
      before :each do
        %x[mkdir #{@test_repo_dir}/spec]
        %w{ a b c }.each do |letter|
          %x[touch #{@test_repo_dir}/spec/#{letter}_spec.rb]
        end

        %x[git --git-dir=#{@test_repo_dir}/.git --work-tree=#{@test_repo_dir} add .]
        %x[git --git-dir=#{@test_repo_dir}/.git --work-tree=#{@test_repo_dir} commit -m "Nothin'"]

        %x[echo "changed" >> #{@test_repo_dir}/spec/a_spec.rb]
        %x[echo "changed" >> #{@test_repo_dir}/spec/b_spec.rb]
      end

      it { should have(2).high_risk_specs }

      it { should have_high_risk_spec(@test_repo_dir + "/spec/a_spec.rb") }
      it { should have_high_risk_spec(@test_repo_dir + "/spec/b_spec.rb") }
    end

    context "repository with changed implementation file that has a spec" do
      before :each do
        %x[mkdir #{@test_repo_dir}/lib]
        %x[touch #{@test_repo_dir}/lib/a.rb]
        %x[touch #{@test_repo_dir}/lib/b.rb]
        %x[mkdir #{@test_repo_dir}/spec]
        %x[touch #{@test_repo_dir}/spec/a_spec.rb]
        %x[touch #{@test_repo_dir}/spec/b_spec.rb]

        %x[git --git-dir=#{@test_repo_dir}/.git --work-tree=#{@test_repo_dir} add .]
        %x[git --git-dir=#{@test_repo_dir}/.git --work-tree=#{@test_repo_dir} commit -m "Nothin'"]

        %x[echo "changed" >> #{@test_repo_dir}/lib/b.rb]
      end

      it { should have(1).high_risk_specs }

      it { should have_high_risk_spec(@test_repo_dir + "/spec/b_spec.rb") }
    end

    context "repository with changed implementation file that does not have a spec" do
      before :each do
        %x[mkdir #{@test_repo_dir}/lib]
        %x[touch #{@test_repo_dir}/lib/a.rb]
        %x[touch #{@test_repo_dir}/lib/b.rb]
        %x[touch #{@test_repo_dir}/lib/c.rb]
        %x[mkdir #{@test_repo_dir}/spec]
        %x[touch #{@test_repo_dir}/spec/a_spec.rb]
        %x[touch #{@test_repo_dir}/spec/b_spec.rb]

        %x[git --git-dir=#{@test_repo_dir}/.git --work-tree=#{@test_repo_dir} add .]
        %x[git --git-dir=#{@test_repo_dir}/.git --work-tree=#{@test_repo_dir} commit -m "Nothin'"]

        %x[echo "changed" >> #{@test_repo_dir}/lib/c.rb]
      end

      it { should have(0).high_risk_specs }
    end

    context "repository with changed implementation file and changed test for implementation" do
      before :each do
        %x[mkdir #{@test_repo_dir}/lib]
        %x[touch #{@test_repo_dir}/lib/a.rb]
        %x[touch #{@test_repo_dir}/lib/b.rb]
        %x[mkdir #{@test_repo_dir}/spec]
        %x[touch #{@test_repo_dir}/spec/a_spec.rb]
        %x[touch #{@test_repo_dir}/spec/b_spec.rb]

        %x[git --git-dir=#{@test_repo_dir}/.git --work-tree=#{@test_repo_dir} add .]
        %x[git --git-dir=#{@test_repo_dir}/.git --work-tree=#{@test_repo_dir} commit -m "Nothin'"]

        %x[echo "changed" >> #{@test_repo_dir}/lib/a.rb]
        %x[echo "changed" >> #{@test_repo_dir}/spec/a_spec.rb]
      end

      it { should have(1).high_risk_specs }

      it { should have_high_risk_spec(@test_repo_dir + "/spec/a_spec.rb") }
    end
  end
end

RSpec::Matchers.define :have_high_risk_spec do |expected_path|
  match { |change_set| change_set.high_risk_specs.include?(expected_path) }
end