# frozen_string_literal: true

require "listen"
require "json"

require "mata/agent"
require "mata/broadcaster"
require "mata/watch_tower"
require "mata/railtie" if defined?(Rails::Railtie)

class Mata
  def initialize(app, options = {})
    @app = app

    @watch_tower = WatchTower.new(options)
    @broadcaster = Broadcaster.new
    @agent = Agent.new

    @watch_tower.on_change { |files| @broadcaster.broadcast_to_all(files) }

    at_exit { stand_down }
  end

  def call(environment)
    request = Rack::Request.new(environment)

    case request.path
    when "/__mata/events"
      @broadcaster.establish_contact(environment)
    when "/__mata/client.js"
      @broadcaster.deliver_payload
    else
      @agent.insert(*@app.call(environment))
    end
  end

  def stand_down
    @watch_tower&.shutdown
    @broadcaster&.stand_down
  end
end
