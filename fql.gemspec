$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "fql/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "fql"
  s.version     = Fql::VERSION
  s.authors     = ["Maarten Claes"]
  s.email       = ["maartencls@gmail.com"]
  s.homepage    = "https://github.com/mcls/fql"
  s.summary     = "Facebook Query Language library"
  s.description = <<-EOF
    A simple gem to easily use the Facebook Query Language. Just specify single
    queries as strings or use hashes to compose multiqueries and send them to
    Facebook using `Fql.execute(query)`.
  EOF

  s.required_ruby_version = '>= 1.9.0'

  s.files = Dir["lib/**/*"] + ["MIT-LICENSE", "Rakefile", "README.markdown"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "multi_json", "~> 1.3.6"

  s.add_development_dependency "webmock"
  s.add_development_dependency "vcr"
  s.add_development_dependency "rspec"
end
