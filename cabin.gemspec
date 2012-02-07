Gem::Specification.new do |spec|
  paths = %w{lib examples test LICENSE CHANGELIST}
  spec.name = "cabin"
  spec.version = "0.3.6"
  spec.summary = "Experiments in structured and contextual logging"
  spec.description = "This is an experiment to try and make logging more " \
    "flexible and more consumable. Plain text logs are bullshit, let's " \
    "emit structured and contextual logs. Metrics, too!"
  spec.license = "Apache License (2.0)"
  spec.authors = ["Jordan Sissel"]
  spec.email = ["jls@semicomplete.com"]
  spec.homepage = "https://github.com/jordansissel/ruby-cabin"

  spec.add_dependency("json")
  spec.require_paths << "lib"

  spec.bindir = "bin"
  spec.executables << "rubygems-cabin-test"

  files = []
  paths.each do |path|
    if File.file?(path)
      files << path
    else
      files += Dir["#{path}/**/*"]
    end
  end

  spec.files = files
end

