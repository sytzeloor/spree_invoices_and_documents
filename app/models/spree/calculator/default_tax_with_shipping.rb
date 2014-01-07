require_dependency 'spree/calculator'

module Spree
  class Calculator::DefaultTaxWithShipping < Calculator::DefaultTax
    def self.description
      Spree.t(:default_tax_with_shipping)
    end

    private

    def compute_order(order)
      matched_line_items = order.line_items.select do |line_item|
        line_item.tax_category == rate.tax_category
      end

      line_items_total = matched_line_items.map(&:total).sum

      adjustment_total_without_tax = order.adjustments.eligible.delete_if { |adjustment| adjustment.originator.is_a?(Spree::TaxRate) }.map(&:amount).sum

      round_to_two_places((line_items_total + adjustment_total_without_tax) * rate.amount)
    end
  end
end
