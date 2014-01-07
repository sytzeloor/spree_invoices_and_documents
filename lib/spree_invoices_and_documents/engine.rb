module SpreeInvoicesAndDocuments
  class Engine < Rails::Engine
    require 'spree/core'
    isolate_namespace Spree
    engine_name 'spree_invoices_and_documents'

    config.autoload_paths += %W(#{config.root}/lib)

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

    initializer 'spree.register.default_tax_with_shipping_calculator', after: 'spree.register.calculators' do |app|
      app.config.spree.calculators.tax_rates += [Spree::Calculator::DefaultTaxWithShipping]
    end

    config.to_prepare &method(:activate).to_proc
  end
end
