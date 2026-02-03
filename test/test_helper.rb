require "minitest/autorun"
require "rack/test"

require "lib/mata"

module TestHelpers
  def setup_temp_directory
    @temp_dir = Dir.mktmpdir
  end

  def teardown_temp_directory
    FileUtils.rm_rf(@temp_dir) if @temp_dir
  end

  def create_test_file(name, content = "test content")
    File.join(@temp_dir, name).tap { File.write(it, content) }
  end

  def wait_for_file_watcher(seconds = 0.3)
    sleep seconds
  end
end
