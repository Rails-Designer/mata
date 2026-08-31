require_relative "test_helper"

class TestWatchTower < Minitest::Test
  include Rack::Test::Methods
  include TestHelpers

  def setup
    @watch_dir = Dir.mktmpdir
    @watch_tower = Mata::WatchTower.new(watch: [@watch_dir])
    @changes = []

    @watch_tower.on_change { |files| @changes.concat(files) }
  end

  def teardown
    @watch_tower.shutdown

    FileUtils.rm_rf(@watch_dir)
  end

  def test_accepts_custom_debounce
    watch_tower = Mata::WatchTower.new(watch: [@watch_dir], debounce: 500)

    assert_equal 500, watch_tower.instance_variable_get(:@debounce)
  ensure
    watch_tower.shutdown
  end

  def test_on_change_callback_fires
    callback_fired = false
    files_received = nil

    @watch_tower.on_change do |files|
      callback_fired = true
      files_received = files
    end

    @watch_tower.instance_variable_get(:@on_change).call(["test.txt"])

    assert callback_fired
    assert_equal ["test.txt"], files_received
  end

  def test_stand_down_stops_watching
    @watch_tower.shutdown
  end
end
