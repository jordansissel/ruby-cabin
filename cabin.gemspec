Gem::Specification.new do |spec|
  paths = %w{lib examples test LICENSE CHANGELIST}
  spec.name = "cabin"
  spec.version = "0.7.1"
  spec.summary = "Experiments in structured and contextual logging"
  spec.description = "This is an experiment to try and make logging more " \
    "flexible and more consumable. Plain text logs are bullshit, let's " \
    "emit structured and contextual logs. Metrics, too!"
  spec.license = "Apache License (2.0)"
  spec.authors = ["Jordan Sissel"]
  spec.email = ["jls@semicomplete.com"]
  spec.homepage = "https://github.com/jordansissel/ruby-cabin"

  spec.require_paths << "lib"

  spec.bindir = "bin"
  spec.executables << "rubygems-cabin-test"

  spec.files = Dir.glob(["cabin.gemspec", "LICENSE", "CHANGELIST",  "lib/**/*.rb", "examples/**/*.rb", "test/**/*.rb"])

  spec.add_development_dependency 'simplecov', '~> 0.10.0'
  spec.add_development_dependency 'minitest', '~> 5.8.0'

  spec.add_runtime_dependency 'ffi-rzmq', '~> 2.0.4'
  spec.add_runtime_dependency 'json', '~> 1.8.3'
end

