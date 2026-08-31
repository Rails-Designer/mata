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
    assert_equal "application/javascript", headers["content-type"]
    assert_includes body.first, "Idiomorph"
    assert_includes body.first, "initMata"
  end

  def test_injects_default_idiomorph_options_when_unset
    _, _, body = Mata::Broadcaster.new.deliver_payload

    assert_includes body.first, "ignoreActiveValue: true"
    refute_includes body.first, "__MATA_IDIOMORPH_OPTIONS__"
  end

  def test_injects_custom_idiomorph_options
    broadcaster = Mata::Broadcaster.new(idiomorph_options: '{ morphStyle: "innerHTML" }')
    _, _, body = broadcaster.deliver_payload

    assert_includes body.first, 'morphStyle: "innerHTML"'
    refute_includes body.first, "__MATA_IDIOMORPH_OPTIONS__"
    refute_includes body.first, "ignoreActiveValue: true"
  end

  def test_rejects_non_string_idiomorph_options
    broadcaster = Mata::Broadcaster.new(idiomorph_options: {morphStyle: "innerHTML"})

    assert_raises(ArgumentError) do
      broadcaster.deliver_payload
    end
  end

  def test_handles_sse_connection
    env = {"REQUEST_METHOD" => "GET"}
    status, headers, _ = @broadcaster.establish_contact(env)

    assert_equal 200, status
    assert_equal "text/event-stream", headers["content-type"]
    assert_equal "no-cache", headers["cache-control"]
    assert_equal "keep-alive", headers["connection"]
  end

  def test_sends_retry_directive_when_configured
    broadcaster = Mata::Broadcaster.new(retry: 3000)
    env = {"REQUEST_METHOD" => "GET"}
    _, _, stream_proc = broadcaster.establish_contact(env)

    output = ""
    stream_proc.call(output)

    assert_includes output, "retry: 3000\n\n"
  end

  def test_omits_retry_directive_when_not_configured
    env = {"REQUEST_METHOD" => "GET"}
    _, _, stream_proc = @broadcaster.establish_contact(env)

    output = ""
    stream_proc.call(output)

    refute_includes output, "retry:"
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
