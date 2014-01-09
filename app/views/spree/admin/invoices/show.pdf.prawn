font_families['Roboto'] = {
  normal: { file: "#{Rails.root}/vendor/fonts/Roboto/Roboto-Regular.ttf", font: 'Roboto', style: :normal },
  bold: { file: "#{Rails.root}/vendor/fonts/Roboto/Roboto-Bold.ttf", font: 'Roboto', style: :bold }
}

font      'Roboto'
font_size 9

define_grid columns: 6, rows: 14, gutter: 6

# Header for all pages
repeat :all do
  # Logo
  grid([0, 0], [0, 2]).bounding_box do
    image "#{Rails.root}/public/static_assets/ultimaker-invoice-logo.png", vposition: :top, height: 40
  end

  # Invoice header
  grid([0, 2], [1, 5]).bounding_box do
    rows = []

    rows << [
      make_cell(Spree.t(:invoice, scope: [:invoices_and_documents, :pdf]), size: 12, font_style: :bold),
      make_cell(@invoice.invoice_number, size: 12, font_style: :bold)
    ]
    rows << [
      make_cell(Spree.t(:order_reference, scope: [:invoices_and_documents, :pdf])),
      make_cell(@invoice.order_reference)
    ]
    rows << [
      make_cell(Spree.t(:date, scope: [:invoices_and_documents, :pdf])),
      make_cell(I18n.l(@invoice.invoice_date, format: :long))
    ]
    if @invoice.order && @invoice.order.respond_to?(:email)
      rows << [
        make_cell(Spree.t(:account, scope: [:invoices_and_documents, :pdf])),
        make_cell(@invoice.order.email)
      ]
    end

    if @invoice.order.respond_to?(:client_reference) && @invoice.order.client_reference.present?
      rows << [
        make_cell(Spree.t(:client_reference, scope: [:invoices_and_documents, :pdf])),
        make_cell(@invoice.order.client_reference)
      ]
    end

    table(rows, position: :right, column_widths: [100, 190], cell_style: { padding: [2, 8], borders: [] }) do
      column(0).style align: :right
      column(1).style align: :left
    end
  end

  if @invoice.order && @invoice.order.respond_to?(:barcode)
    grid([1.15, 3], [3.15, 5]).bounding_box do
      svg @invoice.order.barcode.to_svg, at: [85, 155], width: 200, height: 30
      text_box "#{@invoice.order.number}-#{@invoice.order.checksum}", at: [85, 80], width: 200, size: 8, align: :center
    end
  end

  rows = []

  rows << [
    make_cell(Spree.t(:billing_address, scope: [:invoices_and_documents, :pdf]), font_style: :bold),
    make_cell(Spree.t(:shipping_address, scope: [:invoices_and_documents, :pdf]), font_style: :bold)
  ]

  grid([2.85, 0], [5, 5]).bounding_box do
    shipping_address = @invoice.order.ship_address
    invoice_address = @invoice.invoice_address

    shipping_address_label = []
    shipping_address_label << [shipping_address.firstname, shipping_address.lastname].compact.join(' ')
    shipping_address_label << shipping_address.company unless shipping_address.company.blank?
    shipping_address_label << shipping_address.address1
    shipping_address_label << shipping_address.address2 unless shipping_address.address2.blank?
    shipping_address_label << [shipping_address.city, shipping_address.state_text, shipping_address.zipcode.gsub(/ /, '')].compact.join(', ')
    shipping_address_label << shipping_address.country.name
    shipping_address_label << shipping_address.phone

    invoice_address_label = []
    invoice_address_label << [invoice_address.first_name, invoice_address.last_name].join(' ')
    invoice_address_label << invoice_address.company unless invoice_address.company.blank?
    invoice_address_label << invoice_address.tax_id unless invoice_address.tax_id.blank?
    invoice_address_label << invoice_address.address_1
    invoice_address_label << invoice_address.address_2 unless invoice_address.address_2.blank?
    invoice_address_label << [invoice_address.city, invoice_address.state_name, invoice_address.zipcode.gsub(/ /, '')].compact.join(' ')
    invoice_address_label << invoice_address.country_name

    rows << [
      make_cell(invoice_address_label.join("\n")),
      make_cell(shipping_address_label.join("\n"))
    ]

    table(rows, column_widths: [280, 280], header: true, width: 560, cell_style: { padding: [4, 4] })
  end

  stroke_line [0, 520], [560, 520]
end

# Invoice lines
grid([5.05, 0], [9.6, 5]).bounding_box do
  rows = []

  rows << [
    make_cell(Spree.t(:sku, scope: [:invoices_and_documents, :pdf]), font_style: :bold),
    make_cell(Spree.t(:description, scope: [:invoices_and_documents, :pdf]), font_style: :bold),
    make_cell(Spree.t(:units, scope: [:invoices_and_documents, :pdf]), font_style: :bold),
    make_cell(Spree.t(:unit_price, scope: [:invoices_and_documents, :pdf]), font_style: :bold),
    make_cell(Spree.t(:line_total, scope: [:invoices_and_documents, :pdf]), font_style: :bold)
  ]

  @invoice.invoice_lines.each do |invoice_line|
    rows << [
      make_cell(invoice_line.sku),
      make_cell(invoice_line.description),
      make_cell("#{invoice_line.units} x"),
      make_cell(invoice_line.display_unit_price.to_s),
      make_cell(invoice_line.display_line_total.to_s)
    ]
  end

  table(rows, column_widths: [80, 280, 40, 80, 80], header: true, width: 560, cell_style: { padding: [4, 4] })
end

# Footer for all pages
repeat :all do
  grid([10.5, 0], [10.5, 5]).bounding_box do
    stroke_line [0, 58], [560, 58]
  end

  # Support
  grid([10.5, 0], [12, 3.5]).bounding_box do
    if @invoice.customer_comments
      text Spree.t(:customer_comments, scope: [:invoices_and_documents, :pdf]), style: :bold
      move_down 2
      text @invoice.customer_comments
      move_down 8
    end

    text Spree.t(:footer_support, scope: [:invoices_and_documents, :pdf])
  end

  # Totals
  grid([10.5, 4], [11, 5]).bounding_box do
    rows = []

    rows << [
      make_cell(Spree.t(:sub_total, scope: [:invoices_and_documents, :pdf]), font_style: :bold),
      make_cell(@invoice.display_item_total.to_s)
    ]

    if @invoice.tax_rate != 0
      rows << [
        make_cell("#{Spree.t(:tax, scope: [:invoices_and_documents, :pdf])} #{@invoice.tax_rate * 100}%", font_style: :bold),
        make_cell(@invoice.display_tax_total.to_s)
      ]
    end

    rows << [
      make_cell(Spree.t(:invoice_total, scope: [:invoices_and_documents, :pdf]), font_style: :bold),
      make_cell(@invoice.display_invoice_total.to_s)
    ]

    table(rows, column_widths: [105, 80], width: 185, cell_style: { padding: [4, 4] }) do
      columns(0).style align: :right, borders: [], padding_right: 16
      columns(1).style align: :left
    end
  end

  # Senders address
  grid([12.2, 0], [13, 2]).bounding_box do
    text Spree.t(:senders_address, scope: [:invoices_and_documents, :pdf]), size: 8
  end

  # Senders details
  grid([12.2, 4], [13, 5]).bounding_box do
    text Spree.t(:senders_details, scope: [:invoices_and_documents, :pdf]), size: 8, align: :right
  end
end

number_pages(Spree.t(:pagination, scope: [:invoices_and_documents, :pdf]), {
  at:     [bounds.right - 150, 10],
  width:  150,
  align:  :right,
  start_count_at: 1
})
