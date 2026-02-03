require_relative "test_helper"

class TestBroadcaster < Minitest::Test
  include Rack::Test::Methods
  include TestHelpers

  def setup
    @broadcaster = Mata::Broadcaster.new
  end

  def test_serves_client_script
    status, headers, body = @broadcaster.deliver_payload

    assert_equal 200, status
    assert_equal "application/javascript", headers["Content-Type"]
    assert_includes body.first, "Idiomorph"
    assert_includes body.first, "initMata"
  end

  def test_handles_sse_connection
    env = {"REQUEST_METHOD" => "GET"}
    status, headers, _ = @broadcaster.establish_contact(env)

    assert_equal 200, status
    assert_equal "text/event-stream", headers["Content-Type"]
    assert_equal "no-cache", headers["Cache-Control"]
    assert_equal "keep-alive", headers["Connection"]
  end

  def test_rejects_non_get_sse_requests
    env = {"REQUEST_METHOD" => "POST"}
    status, _, _ = @broadcaster.establish_contact(env)

    assert_equal 405, status
  end

  def test_broadcast_to_all_with_no_clients
    # Should not raise error
    @broadcaster.broadcast_to_all(["file.txt"])
  end

  def test_stand_down_cleans_up
    # Should not raise error
    @broadcaster.stand_down
  end
end
