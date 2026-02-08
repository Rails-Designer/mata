require "rails/railtie"

class Mata
  class Railtie < Rails::Railtie
    class << self
      attr_accessor :watch_paths, :skip_paths

      def configure
        yield(self)
      end
    end

    self.watch_paths = %w[app/views app/assets]
    self.skip_paths = %w[tmp log node_modules]

    config.before_configuration do |app|
      if Rails.env.development?
        app.config.middleware.insert_before(
          ActionDispatch::Static,
          Mata,
          watch: watch_paths,
          skip: skip_paths
        )
      end
    end
  end
end
