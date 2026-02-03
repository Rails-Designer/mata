# frozen_string_literal: true

class Mata
  class Broadcaster
    def initialize
      @clients = []
      @clients_mutex = Mutex.new
      @cleanup_thread = cleanup_periodically
    end

    def establish_contact(env)
      if env["REQUEST_METHOD"] != "GET"
        return [405, {}, []]
      end

      headers = {
        "Content-Type" => "text/event-stream",
        "Cache-Control" => "no-cache",
        "Connection" => "keep-alive",
        "Access-Control-Allow-Origin" => "*"
      }

      [200, headers, proc { |stream|
        @clients_mutex.synchronize do
          @clients << stream
        end

        begin
          stream << "data: {\"type\":\"connected\"}\n\n"

          Thread.new do
            loop { sleep 30 }
          rescue
            @clients_mutex.synchronize { @clients.delete(stream) }
          end
        rescue
          @clients_mutex.synchronize { @clients.delete(stream) }
        end
      }]
    end

    def deliver_payload
      idiomorph_js = File.read(File.join(__dir__, "idiomorph.min.js"))
      client_js = File.read(File.join(__dir__, "client.js"))

      script = "#{idiomorph_js}\n\n#{client_js}"

      [200, {"Content-Type" => "application/javascript"}, [script]]
    end

    def broadcast_to_all(files)
      clients_copy = @clients_mutex.synchronize { @clients.dup }
      return if clients_copy.empty?

      files.each do |file|
        event_data = {type: "reload"}
        message = "data: #{event_data.to_json}\n\n"

        clients_copy.each do |stream|
          stream << message
        rescue
          @clients_mutex.synchronize { @clients.delete(stream) }
        end
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
