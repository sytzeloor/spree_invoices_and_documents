module Spree
  class InvoiceMailer < ActionMailer::Base
    default from: 'Ultimaker Support <support@ultimaker.com>'

    def notify(invoice)
      @invoice = invoice

      prawnto prawn: { page_size: 'A4', margin: 20 }

      attachments['invoice.pdf'] = render('spree/admin/invoices/show', format: :pdf)

      recipient = "#{invoice.invoice_address.first_name} #{invoice.invoice_address.last_name}"
      recipient += " <#{invoice.order.user.email}>"

      subject = Spree.t(:subject, scope: [:invoices_and_documents, :mail, :invoice, invoice.is_credit? ? :credit : :debit], order: invoice.order_reference)

      mail(
        to: recipient,
        subject: subject,
        template_name: invoice.is_credit? ? 'credit' : 'debit'
      )
    end

    def params
      {}
    end
  end
end
