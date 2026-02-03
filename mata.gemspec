require_relative "lib/mata/version"

Gem::Specification.new do |spec|
  spec.name = "mata"
  spec.version = Mata::VERSION
  spec.summary = "Hot module reloading for Rack applications"
  spec.description = "SSE-based hot reloading middleware with DOM morphing"

  spec.authors = ["Rails Designer"]
  spec.email = ["devs@railsdesigner.com"]

  spec.homepage = "https://railsdesigner.com/mata/"
  spec.license = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/Rails-Designer/mata"

  spec.files = Dir["lib/**/*", "README.md"]
  spec.require_paths = ["lib"]

  spec.add_dependency "rack", ">= 3.0"
  spec.add_dependency "listen", "~> 3.0"

  spec.required_ruby_version = ">= 3.4"
end
