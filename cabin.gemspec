Gem::Specification.new do |spec|
  files = []
  paths = %w{lib examples test}
  paths.each do |path|
    if File.file?(path)
      files << path
    else
      files += Dir["#{path}/**/*"]
    end
  end

  spec.name = "cabin"
  spec.version = "0.1.0"
  spec.summary = "Experiments in structured and contextual logging"
  spec.description = "This is an experiment to try and make logging more " \
    "flexible and more consumable. Plain text logs are bullshit, let's " \
    "emit structured and contextual logs."
  spec.license = "Apache License (2.0)"

  spec.add_dependency("json")

  spec.files = files
  spec.require_paths << "lib"
  #spec.bindir = "bin"

  spec.authors = ["Jordan Sissel"]
  spec.email = ["jls@semicomplete.com"]
  spec.homepage = "https://github.com/jordansissel/ruby-cabin"
end

