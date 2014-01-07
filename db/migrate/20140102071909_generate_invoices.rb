class GenerateInvoices < ActiveRecord::Migration
  def up
    Spree::Invoice.destroy_all
    Spree::Order.complete.each do |order|
      next unless order.payments.any?
      order.send(:create_invoice, order.invoice_number)
    end
  end

  def down
    Spree::Invoice.destroy_all
  end
end
