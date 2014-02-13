module Spree
  class InvoiceLine < ActiveRecord::Base
    belongs_to :invoice
    belongs_to :reference, polymorphic: true

    default_scope -> { order(:order) }

    validate :description, presence: true
    validate :unit_price, numericality: true
    validate :units, numericality: { only_integer: true }
    validate :order, uniqueness: { scope: :invoice }

    def display_unit_price
      Spree::Money.new(unit_price, { currency: invoice.currency })
    end

    def line_total
      unit_price * units
    end

    def display_line_total
      Spree::Money.new(line_total, { currency: invoice.currency })
    end

    def harmonized_code
      if reference && reference.respond_to?(:product) && reference.product.respond_to?(:harmonized_code)
        reference.product.harmonized_code
      end
    end
  end
end
