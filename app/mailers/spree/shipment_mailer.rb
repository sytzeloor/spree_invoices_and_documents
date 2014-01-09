module Spree
  class ShipmentMailer < ActionMailer::Base
    default from: 'Ultimaker Support <support@ultimaker.com>'

    def notify(shipment)
      @shipment = shipment
      @invoice = shipment.order.invoices.debit.last

      prawnto prawn: { page_size: 'A4', margin: 20 }

      attachments['invoice.pdf'] = render('spree/admin/invoices/show', format: :pdf) if @invoice
      attachments['packaging_slip.pdf'] = render('spree/admin/shipment_documents/packaging_slip', format: :pdf)
      attachments['non_wood.pdf'] = render('spree/admin/shipment_documents/non_wood', format: :pdf) if %(AUS).include?(shipment.order.ship_address.country.try(:iso3))

      recipient = "Printer Logistiek Ultimaker <printer-logistiek@ultimaker.com>"

      subject = Spree.t(:subject, scope: [:invoices_and_documents, :mail, :shipment], order: shipment.order.number)

      mail(
        to: recipient,
        subject: subject
      )
    end

    def params
      {}
    end
  end
end
