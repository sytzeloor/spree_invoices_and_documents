# encoding: UTF-8
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_invoices_and_documents'
  s.version     = '2.1.3'
  s.summary     = 'Invoices and documents like packing slips for Spree Commerce'
  s.description = ''
  s.required_ruby_version = '>= 2.0.0'

  s.author    = 'Sytze Loor - Tweedledum'
  s.email     = 'sytze@tweedledum.eu'
  s.homepage  = 'http://www.tweedledum.eu'

  s.files       = `git ls-files`.split("\n")
  s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'spree_core', '~> 2.1.3'
  s.add_dependency 'cocoon', '~> 1.2.5'
  s.add_dependency 'prawnto_2', '~> 0.2.6'
  s.add_dependency 'prawn-svg', '~> 0.9.1.10'
  s.add_dependency 'has_barcode', '~> 0.2.3'
  s.add_dependency 'rails-observers', '~> 0.1.2'

  s.add_development_dependency 'capybara', '~> 2.1'
  s.add_development_dependency 'coffee-rails'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'factory_girl', '~> 4.2'
  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'rspec-rails',  '~> 2.13'
  s.add_development_dependency 'sass-rails'
  s.add_development_dependency 'selenium-webdriver'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'sqlite3'
end
