require "minitest/autorun"
require "rack/test"

require "lib/mata"

module TestHelpers
  def setup_temp_directory
    @watch_dir = Dir.mktmpdir
  end

  def teardown_temp_directory
    FileUtils.rm_rf(@watch_dir) if @watch_dir
  end

  def create_test_file(name, content = "test content")
    File.join(@watch_dir, name).tap { File.write(it, content) }
  end

  def wait_for_file_watcher(seconds = 0.3)
    sleep seconds
  end
end
