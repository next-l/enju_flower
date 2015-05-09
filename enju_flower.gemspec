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
  s.test_files = Dir["spec/**/*"] - Dir["spec/dummy/log/*"] - Dir["spec/dummy/solr/{data,pids,default,development,test}/*"] - Dir["spec/dummy/tmp/*"]

  # s.add_dependency "jquery-rails"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "mysql2"
  s.add_development_dependency "pg"
  s.add_development_dependency "rspec-rails", "~> 3.2"
  s.add_development_dependency "vcr"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "factory_girl_rails"
  s.add_development_dependency "sunspot_solr", "~> 2.2"
  s.add_development_dependency "enju_leaf", "~> 1.1.0.rc18"
  s.add_development_dependency "enju_manifestation_viewer", "~> 0.1.0.pre18"
  s.add_development_dependency "enju_circulation", "~> 0.1.0.pre44"
  s.add_development_dependency "enju_bookmark", "~> 0.1.2.pre22"
  s.add_development_dependency "enju_subject", "~> 0.1.0.pre30"
  s.add_development_dependency "mobylette"
  s.add_development_dependency "sunspot-rails-tester"
  s.add_development_dependency "rspec-activemodel-mocks"
  s.add_development_dependency "capybara"
  s.add_development_dependency "appraisal"
end
