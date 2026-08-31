# frozen_string_literal: true

class Mata
  class Broadcaster
    DEFAULT_IDIOMORPH_OPTIONS = <<~JS
      {
        ignoreActiveValue: true,
        callbacks: {
          beforeNodeMorphed: function(oldNode, _) {
            if (oldNode.tagName && oldNode.tagName.includes("-")) {
              return false;
            }

            return true;
          }
        }
      }
    JS

    def initialize(options = {})
      @clients = []
      @clients_mutex = Mutex.new
      @retry = options[:retry]
      @idiomorph_options = options[:idiomorph_options]
      @cleanup_thread = cleanup_periodically
    end

    def establish_contact(env)
      if env["REQUEST_METHOD"] != "GET"
        return [405, {}, []]
      end

      headers = {
        "content-type" => "text/event-stream",
        "cache-control" => "no-cache",
        "connection" => "keep-alive",
        "access-control-allow-origin" => "*"
      }

      [200, headers, proc { |stream|
        @clients_mutex.synchronize do
          @clients << stream
        end

        begin
          stream << "retry: #{@retry}\n\n" if @retry
          stream << "data: {\"type\":\"connected\"}\n\n"
        rescue
          @clients_mutex.synchronize { @clients.delete(stream) }
        end
      }]
    end

    def deliver_payload
      raise ArgumentError, "idiomorph_options must be a String containing a raw JS object literal" if @idiomorph_options && !@idiomorph_options.is_a?(String)

      idiomorph_js = File.read(File.join(__dir__, "idiomorph.min.js"))
      client_js = File.read(File.join(__dir__, "client.js"))

      client_js = client_js.gsub("__MATA_IDIOMORPH_OPTIONS__", @idiomorph_options || DEFAULT_IDIOMORPH_OPTIONS)

      script = "#{idiomorph_js}\n\n#{client_js}"

      [200, {"content-type" => "application/javascript"}, [script]]
    end

    def broadcast_to_all(files)
      clients_copy = @clients_mutex.synchronize { @clients.dup }
      return if clients_copy.empty?

      event_data = {type: "reload", files: files}
      message = "data: #{event_data.to_json}\n\n"

      clients_copy.each do |stream|
        stream << message
      rescue
        @clients_mutex.synchronize { @clients.delete(stream) }
      end
    end

    def stand_down
      @cleanup_thread&.kill

      @clients_mutex.synchronize { @clients.clear }
    end

    private

    def cleanup_periodically
      Thread.new do
        loop do
          sleep 60

          cleanup_dead_clients
        end
      rescue
      end
    end

    def cleanup_dead_clients
      @clients_mutex.synchronize do
        @clients.reject! do |client|
          client << ""

          false
        rescue
          true
        end
      end
    end
  end
end
