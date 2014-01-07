require 'digest/sha1'
require 'barby/barcode/code_128'

module Spree
  Order.class_eval do
    # Barcodes
    include HasBarcode

    has_barcode :barcode,
      outputter: :svg,
      type: Barby::Code128A,
      value: Proc.new { |order| "#{order.number}-#{order.checksum}" }

    def checksum
      Digest::SHA1.base64digest([
        item_total.to_s,
        adjustment_total.to_s,
        shipping_total.to_s,
        tax_total.to_s,
        eval(completed_at.to_json)
      ].join)[0..10].upcase
    end

    def shipping_total
      shipments.sum { |shipment| shipment.cost.to_f }
    end

    # Invoices
    has_many :invoices, dependent: :nullify

    set_callback :commit, :after, :create_invoice

    private

    def create_invoice(number = nil, is_credit = false)
      return if payments.none? || !completed?

      generate = false

      if invoices.none?
        # initial invoice, continue
        generate = true
      elsif is_credit
        # create invoice when order is canceled, based upon last complete invoice
        generate = canceled? && invoices.any? && !invoices.last.is_credit?
      elsif !is_credit
        # create invoice when order is resumed
        generate = resumed? && invoices.any? && invoices.last.is_credit?
      end

      if generate
        invoice_line_items = []

        item_count = 1

        line_items.each do |line_item|
          invoice_line_items << {
            reference: line_item.variant,
            order: item_count,
            sku: line_item.variant.sku,
            description: [line_item.variant.product.name, line_item.variant.option_values.empty? ? nil : "(#{line_item.variant.options_text})"].compact.join(' '),
            unit_price: line_item.price,
            units: is_credit ? line_item.quantity * -1 : line_item.quantity,
            taxable: true,
            tax_included: false
          }

          item_count += 1
        end


        adjustments.eligible.each do |adjustment|
          next if %w(Spree::TaxRate Spree::ShippingMethod).include?(adjustment.originator_type)

          invoice_line_items << {
            reference: adjustment,
            order: item_count,
            sku: '',
            description: adjustment.label,
            unit_price: adjustment.amount,
            units: is_credit ? -1 : 1,
            taxable: true,
            tax_included: false
          }

          item_count += 1
        end


        adjustments.eligible.shipping.each do |shipping_adjustment|
          invoice_line_items << {
            reference: shipping_adjustment,
            order: item_count,
            sku: shipping_adjustment.label.downcase,
            description: shipping_adjustment.source.shipping_method.name,
            unit_price: shipping_adjustment.amount,
            units: is_credit ? -1 : 1,
            taxable: true,
            tax_included: false
          }

          item_count += 1
        end


        tax_rates = Spree::TaxRate.match(self)
        tax_rate_amount = tax_rates.any? ? tax_rates.first.amount : 0

        invoice = invoices.build(
          invoice_number: number,
          invoice_date: completed_at,
          tax_rate: tax_rate_amount,
          customer_comments: special_instructions,
          invoice_lines_attributes: invoice_line_items
        )

        invoice.save!
      end
    end

    alias_method :original_after_cancel, :after_cancel
    def after_cancel
      create_invoice(nil, true)

      original_after_cancel
    end

    alias_method :original_after_resume, :after_resume
    def after_resume
      create_invoice

      original_after_resume
    end
  end
end
