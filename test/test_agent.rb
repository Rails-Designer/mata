require_relative "test_helper"

class TestAgent < Minitest::Test
  include Rack::Test::Methods
  include TestHelpers

  def setup
    @agent = Mata::Agent.new
  end

  def test_inserts_script_into_html
    html = "<html><head></head><body>Content</body></html>"
    status, _, body = @agent.insert(200, {"Content-Type" => "text/html"}, [html])

    assert_equal 200, status
    assert_includes body.first, '<script src="/__mata/client.js"></script>'
    assert_includes body.first, "</head>"
  end

  def test_skips_non_html_responses
    json = '{"data": "value"}'
    _, _, body = @agent.insert(200, {"Content-Type" => "application/json"}, [json])

    assert_equal [json], body
  end

  def test_skips_html_without_head_tag
    html = "<div>No head tag</div>"
    _, _, body = @agent.insert(200, {"Content-Type" => "text/html"}, [html])

    assert_equal [html], body
  end

  def test_updates_content_length_header
    html = "<html><head></head><body></body></html>"

    _, headers, _ = @agent.insert(200, {"Content-Type" => "text/html", "Content-Length" => "39"}, [html])
    refute_equal "39", headers["Content-Length"]

    assert headers["Content-Length"].to_i > 39
  end

  def test_handles_chunked_body
    html = ["<html><head>", "</head><body></body></html>"]
    _, _, body = @agent.insert(200, {"Content-Type" => "text/html"}, html)

    assert_includes body.first, '<script src="/__mata/client.js"></script>'
  end
end
