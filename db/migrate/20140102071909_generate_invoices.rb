class GenerateInvoices < ActiveRecord::Migration
  def up
    Spree::Config.set(:enable_mail_delivery, false)
    Spree::Invoice.destroy_all
    Spree::Order.complete.each do |order|
      next unless order.payments.any?
      order.send(:create_invoice, order.invoice_number)
    end
    Spree::Config.set(:enable_mail_delivery, true)
  end

  def down
    Spree::Invoice.destroy_all
  end
end
