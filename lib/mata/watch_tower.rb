# frozen_string_literal: true

class Mata
  class WatchTower
    def initialize(options)
      @watch_paths = Array(options[:watch] || %w[app views assets])
      @skip_paths = skipped_patterns(options[:skip] || options[:ignore] || %w[tmp log])
      @on_change = nil
      @listener = nil

      observe!
    end

    def on_change(&block)
      @on_change = block
    end

    def shutdown
      @listener&.stop
    end

    private

    def skipped_patterns(skip_paths)
      skip_paths.map do |path|
        case path
        when Regexp
          path
        when String
          escaped = Regexp.escape(path)
          /#{escaped}/
        else
          /#{Regexp.escape(path.to_s)}/
        end
      end
    end

    def observe!
      @last_change_time = nil

      @listener = Listen.to(*@watch_paths, ignore: @skip_paths) do |modified, added, removed|
        @last_change_time = Time.now

        Thread.new do
          sleep 0.15
          if Time.now - @last_change_time >= 0.15
            @on_change&.call(modified + added + removed)
          end
        end
      end

      @listener.start
    end
  end
end
