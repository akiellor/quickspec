require 'rubygems'
require 'rake/gempackagetask'
require 'spec/rake/spectask'

spec = Gem::Specification.new do |s|
  s.author = 'Andrew Kiellor'
  s.email = 'akiellor@gmail.com'
  s.platform = Gem::Platform::RUBY
  s.summary = "A tool for quickly running a subset of tests relevant to a change set."
  s.name = 'quicktest'
  s.version = 0.1
  s.require_path = 'lib'
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end

Spec::Rake::SpecTask.new do |t|
  t.warning = true
end
