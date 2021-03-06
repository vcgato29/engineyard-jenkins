module CommonHelpers
  def get_command_output
    strip_color_codes(File.read(@stdout)).chomp
  end

  def strip_color_codes(text)
    text.gsub(/\e\[\d+m/, '')
  end

  def in_tmp_folder(&block)
    FileUtils.chdir(@tmp_root, &block)
  end

  def in_project_folder(&block)
    project_folder = @active_project_folder || @tmp_root
    FileUtils.chdir(project_folder, &block)
  end

  def in_home_folder(&block)
    FileUtils.chdir(@home_path, &block)
  end

  def force_local_lib_override(project_name = @project_name)
    rakefile = File.read(File.join(project_name, 'Rakefile'))
    File.open(File.join(project_name, 'Rakefile'), "w+") do |f|
      f << "$:.unshift('#{@lib_path}')\n"
      f << rakefile
    end
  end

  def setup_active_project_folder project_name
    @active_project_folder = File.join(@tmp_root, project_name)
    @project_name = project_name
  end

  # capture both [stdout, stderr] as well as stdin
  def capture_stdios(input = nil, &block)
    require 'stringio'
    org_stdin, $stdin = $stdin, StringIO.new(input) if input
    org_stdout, $stdout = $stdout, StringIO.new
    org_stderr, $stderr = $stdout, StringIO.new
    yield
    return [$stdout.string, $stderr.string]
  ensure
    $stderr = org_stderr
    $stdout = org_stdout
    $stdin = org_stdin
  end
end
  
World(CommonHelpers)