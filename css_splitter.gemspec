$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "css_splitter/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "css_splitter"
  s.version     = CssSplitter::VERSION
  s.authors     = ["Christian Peters", "Jakob Hilden"]
  s.email       = ["christian.peters@zweitag.de", "jakobhilden@gmail.com"]
  s.homepage    = "https://github.com/zweilove/css_splitter"
  s.summary     = "CSS stylesheet splitter for Rails"
  s.description = "Gem for splitting up stylesheets that go beyond the IE limit of 4095 selectors, for Rails 3.1+ apps using the Asset Pipeline."
  s.license = 'MIT'

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", ">= 3.1"
end
