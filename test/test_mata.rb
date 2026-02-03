require_relative "test_helper"

class TestMata < Minitest::Test
  include Rack::Test::Methods
  include TestHelpers

  def setup
    setup_temp_directory

    @app = lambda { |env| [200, {"Content-Type" => "text/html"}, ["<html><head></head><body>Hello</body></html>"]] }
    @mata = Mata.new(@app, watch: [@temp_dir], skip: ["tmp"])
  end

  def teardown
    @mata.stand_down

    teardown_temp_directory
  end

  def app
    @mata
  end

  def test_injects_script_into_html_responses
    get "/"

    assert_includes last_response.body, '<script src="/__mata/client.js"></script>'
  end

  def test_serves_client_script
    get "/__mata/client.js"

    assert_equal 200, last_response.status
    assert_equal "application/javascript", last_response.content_type
    assert_includes last_response.body, "Idiomorph"
  end

  def test_handles_sse_connection
    get "/__mata/events"

    assert_equal 200, last_response.status
    assert_equal "text/event-stream", last_response.content_type
  end

  def test_passes_through_other_requests
    get "/other"

    assert_includes last_response.body, "Hello"
    assert_includes last_response.body, '<script src="/__mata/client.js"></script>'
  end
end
