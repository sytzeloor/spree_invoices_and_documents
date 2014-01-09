require 'prawnto'
require 'prawn-svg'

class GenerateAndSaveCurrentInvoicesToDocuments < ActiveRecord::Migration
  def up
    Spree::Document.where(source_type: 'Spree::Order').where('document_file_name LIKE ?', 'invoice%.pdf').destroy_all

    Spree::Order.all.each do |order|
      next unless order.payments.any? && order.invoice_number.present? && !order.completed_at.blank? && order.bill_address.present? && order.ship_address.present?

      template = File.read(Rails.root.join('app/views/spree/admin/orders/invoice.pdf.prawn'))

      pdf = Prawn::Document.new(page_size: 'A4', page_layout: :portrait, margin: 20)

      pdf.instance_eval do
        @order = order
        eval(template)
      end

      file = Tempfile.new(['invoice', '.pdf'], encoding: 'ascii-8bit')
      file.write pdf.render
      file.close

      document = order.documents.build({
        name: "Invoice #{order.invoice_number}",
        description: 'File generated and saved by migration for future reference.',
        document: File.new(file.path, 'r')
      })
      document.save!

      file.unlink
    end
  end

  def down
    Spree::Document.where(source_type: 'Spree::Order').where('document_file_name LIKE ?', 'invoice%.pdf').destroy_all
  end
end
