module Spree
  class Invoice < ActiveRecord::Base
    belongs_to :order
    belongs_to :invoice_address
    has_many :invoice_lines, dependent: :destroy

    default_scope -> { order(:invoice_number) }

    validate :order_id, :invoice_address_id, presence: true
    validate :invoice_number, :invoice_date, presence: true
    validate :invoice_number, uniqueness: true
    validate :tax_rate, nummericality: { greater_than_or_equal_to: 0, less_then_or_equal_to: 1 }
    validate :tax_total, :item_total, :invoice_total, nummericality: true

    accepts_nested_attributes_for :invoice_address, :invoice_lines, :reject_if => :all_blank, :allow_destroy => true

    set_callback :initialize, :after, :set_invoice_number
    set_callback :initialize, :after, :set_invoice_date
    set_callback :initialize, :after, :set_order_reference
    set_callback :initialize, :after, :set_invoice_address
    set_callback :initialize, :after, :set_tax_rate
    set_callback :validation, :before, :set_invoice_number
    set_callback :save, :after, :set_credit_debit, :set_invoice_total, :set_tax_total, :set_item_total
    set_callback :destroy, :after, :delete_invoice_address

    def self.next_invoice_number
      (Spree::Invoice.order(:invoice_number).where('invoice_number IS NOT NULL AND invoice_number != 0').last.try(:invoice_number) || Spree::Config[:invoice_number_start] || 0) + 1
    end

    def invoice_recipient
      return unless invoice_address.present?
      return [invoice_address.first_name, invoice_address.last_name].compact.join(' ') if invoice_address.has_name?
      invoice_address.company if invoice_address.has_company?
    end

    def currency
      if order && order.currency?
        order.currency
      else
        Spree::Config[:currency]
      end
    end

    def display_item_total
      Spree::Money.new(item_total, { currency: currency })
    end

    def display_tax_total
      Spree::Money.new(tax_total, { currency: currency })
    end

    def display_invoice_total
      Spree::Money.new(invoice_total, { currency: currency })
    end

    private

    def delete_invoice_address
      invoice_address.destroy!
    end

    def set_invoice_date
      return if invoice_date.present?
      self.invoice_date = Date.today
    end

    def set_invoice_number
      return if invoice_number.present?
      self.invoice_number = Invoice.next_invoice_number
    end

    def set_tax_rate
      return if tax_rate.present?
      self.tax_rate = order.tax_zone.tax_rates.first.amount
    end

    def set_order_reference
      return if order_reference.present? || !order
      self.order_reference = "#{order.number}-#{(order.invoices.count + 1)}"
    end

    def set_invoice_address
      return if invoice_address.present?
      self.invoice_address = build_invoice_address(order: order)
    end

    def set_item_total
      item_total = 0

      invoice_lines.each do |line|
        item_total += line.unit_price * line.units
      end

      self.update_column(:item_total, item_total)
    end

    def set_tax_total
      tax_total = 0

      invoice_lines.each do |line|
        next if !line.taxable? || line.tax_included?
        item_total = line.unit_price * line.units
        tax_total += item_total * self.tax_rate
      end

      self.update_column(:tax_total, tax_total)
    end

    def set_invoice_total
      self.update_column(:invoice_total, self.tax_total + self.item_total)
    end

    def set_credit_debit
      self.update_column(:is_credit, invoice_total < 0)
    end
  end
end
