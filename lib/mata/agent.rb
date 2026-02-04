# frozen_string_literal: true

class Mata
  class Agent
    def insert(status, headers, body)
      return [status, headers, body] unless html_response?(headers)

      content = extract(body)
      return [status, headers, [content]] unless content.include?("</head>")

      script_tag = '<script src="/__mata/client.js"></script>'
      modified_content = content.sub("</head>", "#{script_tag}\n</head>")

      headers["Content-Length"] = modified_content.bytesize.to_s if headers["Content-Length"]

      [status, headers, [modified_content]]
    end

    private

    def html_response?(headers)
      content_type = headers["Content-Type"] || headers["content-type"]

      content_type&.include?("text/html")
    end

    def extract(body)
      if body.respond_to?(:each)
        body.each.to_a.join
      else
        body.to_s
      end
    end
  end
end
