$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "tellimus/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "tellimus"
  s.version     = Tellimus::VERSION
  s.authors     = ["Tyler Horan"]
  s.email       = ["tyler@tylerhoran.com@"]
  s.homepage    = "http://github.com/tylerhoran/tellimus"
  s.summary     = %q{Robust subscription support for Rails with Braintree.}
  s.description = %q{Robust subscription support for Rails with Braintree. Provides package levels, logging, notifications, etc.}
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails"
  s.add_dependency "braintree"
  s.add_dependency 'bluecloth'

  s.add_development_dependency "jquery-rails"
  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails", ">= 3.0.0"
  s.add_development_dependency 'capybara'
  s.add_development_dependency 'factory_bot_rails'
  s.add_development_dependency 'pry'
end
