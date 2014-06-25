$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "enju_flower/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "enju_flower"
  s.version     = EnjuFlower::VERSION
  s.authors     = ["Kosuke Tanabe"]
  s.email       = ["nabeta@fastmail.fm"]
  s.homepage    = "https://github.com/next-l/enju_flower"
  s.summary     = "Next-L Enju Flower"
  s.description = "User interface for Next-L Enju"

  s.files = Dir["{app,config,db,lib,vendor}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"] - Dir["spec/dummy/log/*"] - Dir["spec/dummy/solr/{data,pids}/*"]

  s.add_dependency "rails", "~> 4.1"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "vcr"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "factory_girl_rails"
  #s.add_development_dependency "enju_leaf", "~> 1.2.0.pre1"
  #s.add_development_dependency "enju_bookmark", "~> 0.2.0.pre1"
  s.add_development_dependency "elasticsearch-extensions"
end
