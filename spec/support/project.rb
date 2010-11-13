class Project
  def initialize(working_dir)
    @working_dir = working_dir
    @spec_dir = working_dir + "/spec"
    @lib_dir = working_dir + "/lib"
  end

  def spec name
    @spec_dir + "/" + name + "_spec.rb"
  end

  def lib name
    @lib_dir + "/" + name + ".rb"
  end

  def root name
    @working_dir + "/" + name
  end

  def clean
    FileUtils.rm_r @working_dir
    Dir.mkdir @working_dir
  end

  def change file
    %x[echo "changed" >> #{file}]
  end

  def change_lib name
    %x[echo "changed" >> #{lib name}]
  end

  def change_spec name
    %x[echo "changed" >> #{spec name}]
  end

  def commit_all
    %x[git --git-dir=#{@working_dir}/.git --work-tree=#{@working_dir} add .]
    %x[git --git-dir=#{@working_dir}/.git --work-tree=#{@working_dir} commit -m "Nothin'"]
  end

  def init
    %x[touch #{@working_dir}/README]
    %x[git init #{@working_dir}]
    %x[git --git-dir=#{@working_dir}/.git --work-tree=#{@working_dir} add .]
    %x[git --git-dir=#{@working_dir}/.git --work-tree=#{@working_dir} commit -m 'Initial commit.']
  end

  def make_libs * names
    names.each { |name| make lib name }
  end

  def make_specs * names
    names.each { |name| make spec name }
  end

  def make_root file
    make root file
  end

  def make name
    Dir.mkdir @lib_dir unless File.exist? @lib_dir
    Dir.mkdir @spec_dir unless File.exist? @spec_dir
    File.new(name, "w+").close
  end
end