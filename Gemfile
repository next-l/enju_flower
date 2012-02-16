source 'https://rubygems.org'

gem 'rails', '3.2.1'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'enju_bookmark', :git => 'git://github.com/nabeta/enju_bookmark.git'
gem 'enju_oai', :git => 'git://github.com/nabeta/enju_oai.git'

platforms :ruby do
  gem 'pg'
  #gem 'mysql2', '~> 0.3'
  #gem 'sqlite3'
  gem 'ruby-prof', :group => [:development, :test]
  gem 'zipruby'
  gem 'kgio'
end

platforms :ruby_19 do
  gem 'simplecov', '~> 0.5', :require => false, :group => :test
end

platforms :ruby_18 do
  gem 'system_timer'
end

platforms :jruby do
  gem 'jruby-openssl'
  gem 'activerecord-jdbc-adapter'
  gem 'jdbc-postgres', :require => false
  #gem 'jdbc-mysql', :require => false
  gem 'rubyzip2'
  gem 'glassfish'
end

gem 'fastercsv' if RUBY_VERSION < '1.9'

gem 'will_paginate', '~> 3.0'
gem 'exception_notification', '~> 2.5.2'
gem 'configatron'
gem 'delayed_job_active_record'
gem 'state_machine', '~> 1.1.2'
gem 'sunspot_rails', '~> 2.0.0.pre.111215'
gem 'sunspot_solr', '~> 2.0.0.pre.111215'
gem 'progress_bar'
gem 'friendly_id', '~> 4.0'
gem 'inherited_resources', '~> 1.3'
gem 'has_scope'
gem 'nokogiri'
gem 'marc'
#gem 'attr_encryptor'
gem 'dalli', '~> 1.1'
gem 'sitemap_generator', '~> 3.0'
gem 'ri_cal'
gem 'file_wrapper'
gem 'paper_trail', '~> 2.6'
gem 'recurrence'
gem 'RedCloth', '>= 4.2.9'
gem 'isbn-tools', :git => 'git://github.com/nabeta/isbn-tools.git', :require => 'isbn/tools'
gem 'attribute_normalizer', '~> 1.0'
gem 'cancan', '>= 1.6.7'
gem 'devise', '~> 2.0'
gem 'omniauth', '~> 1.0'
gem 'addressable'
gem 'paperclip', '~> 2.6'
gem "aws-sdk", '~> 1.3'
gem 'whenever', '~> 0.6', :require => false
gem 'astrails-safe'
gem 'dynamic_form'
gem 'sanitize'
gem 'mobile-fu'
#gem 'geokit'
gem 'geocoder'
gem 'acts_as_list', :git => 'git://github.com/swanandp/acts_as_list.git'
gem 'library_stdnums'
gem 'client_side_validations', '~> 3.2.0.beta.2'
gem 'simple_form', '~> 1.5'
gem 'validates_timeliness'
gem 'rack-protection'
gem 'awesome_nested_set', '~> 2.1'
gem 'rails_autolink'

#gem 'oink', '>=0.9.2'
group :development do
  gem 'parallel_tests'
  gem 'annotate'
end

group :development, :test do
  gem 'rspec-rails', '~> 2.8.1'
  gem 'guard-rspec'
  gem 'factory_girl_rails', '~> 1.6'
  gem 'spork-rails'
  gem 'rcov', '0.9.11'
  gem 'metric_fu', '~> 2.1'
  gem 'timecop'
  gem 'sunspot-rails-tester', :git => 'git://github.com/nabeta/sunspot-rails-tester.git'
  gem 'vcr', '~> 2.0.0.rc1'
  gem 'fakeweb'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer'

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'
