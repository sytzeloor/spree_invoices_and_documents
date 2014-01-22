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
      make_cell(Spree.t(:non_wood, scope: [:invoices_and_documents, :pdf]), size: 12, font_style: :bold),
      make_cell(@shipment.number, size: 12, font_style: :bold)
    ]
    rows << [
      make_cell(Spree.t(:order_reference, scope: [:invoices_and_documents, :pdf])),
      make_cell(@shipment.order.number)
    ]

    if @shipment.shipped_at
      rows << [
        make_cell(Spree.t(:shipped_at, scope: [:invoices_and_documents, :pdf])),
        make_cell(I18n.l(@shipment.shipped_at, format: :long))
      ]
    elsif @shipment.order.completed_at
      rows << [
        make_cell(Spree.t(:completed_at, scope: [:invoices_and_documents, :pdf])),
        make_cell(I18n.l(@shipment.order.completed_at, format: :long))
      ]
    end

    if @shipment.order.respond_to?(:email)
      rows << [
        make_cell(Spree.t(:account, scope: [:invoices_and_documents, :pdf])),
        make_cell(@shipment.order.email)
      ]
    end

    if @shipment.order.respond_to?(:client_reference) && @shipment.order.client_reference.present?
      rows << [
        make_cell(Spree.t(:client_reference, scope: [:invoices_and_documents, :pdf])),
        make_cell(@shipment.order.client_reference)
      ]
    end

    table(rows, position: :right, column_widths: [100, 190], cell_style: { padding: [2, 8], borders: [] }) do
      column(0).style align: :right
      column(1).style align: :left
    end
  end

  if @shipment.tracking && @shipment.respond_to?(:barcode)
    grid([1.15, 0], [3.15, 2]).bounding_box do
      svg @shipment.barcode.to_svg, at: [0, 153], width: 200, height: 25
      text_box @shipment.tracking, at: [0, 80], width: 200, size: 8, align: :center
    end
  end

  if @shipment.order.respond_to?(:barcode)
    grid([1.15, 3], [3.15, 5]).bounding_box do
      svg @shipment.order.barcode.to_svg, at: [85, 153], width: 200, height: 25
      text_box "#{@shipment.order.number}-#{@shipment.order.checksum}", at: [85, 80], width: 200, size: 8, align: :center
    end
  end

  stroke_line [0, 635], [560, 635]
end

# Statement
grid([4.05, 0], [9.6, 5]).bounding_box do
  font_size 12

  text Spree.t(:non_wood_header, scope: [:invoices_and_documents, :pdf]), size: 14, align: :center, style: :bold

  move_down 8

  rows = []

  rows << [
    make_cell(Spree.t(:to, scope: [:invoices_and_documents, :pdf]), font_style: :bold),
    make_cell([[@shipment.order.ship_address.firstname, @shipment.order.ship_address.lastname].join(' '), @shipment.order.ship_address.company].delete_if(&:blank?).compact.join(' - '))
  ]
  rows << [
    make_cell("#{Spree.t(:it_is_declared_that_this_shipment, scope: [:invoices_and_documents, :pdf])}:", colspan: 2),
  ]
  rows << [
    make_cell(Spree.t(:order_reference, scope: [:invoices_and_documents, :pdf]), font_style: :bold),
    make_cell(@shipment.order.number)
  ]
  rows << [
    make_cell(Spree.t(:number_of_packages, scope: [:invoices_and_documents, :pdf]), font_style: :bold),
    make_cell(params[:packages] || '')
  ]
  rows << [
    make_cell(Spree.t(:weight, scope: [:invoices_and_documents, :pdf]), font_style: :bold),
    make_cell("#{@shipment.to_package.weight} #{Spree.t(:weight_label, scope: [:invoices_and_documents, :pdf])}")
  ]
  rows << [
    make_cell(Spree.t(:does_not_contain_wood, scope: [:invoices_and_documents, :pdf]), colspan: 2),
  ]

  table(rows, column_widths: [280, 280], header: true, width: 560, cell_style: { padding: [4, 4] }) do
    column(0).style align: :right
    row(1).style align: :center
    row(5).style align: :center
  end

  move_down 12

  rows = []

  rows << [
    make_cell(Spree.t(:shipper_label, scope: [:invoices_and_documents, :pdf]), font_style: :bold),
    make_cell(Spree.t(:shipper, scope: [:invoices_and_documents, :pdf]))
  ]
  rows << [
    make_cell(Spree.t(:date, scope: [:invoices_and_documents, :pdf]), font_style: :bold),
    make_cell(l(@shipment.shipped? ? @shipment.shipped_at : Date.today, format: :long))
  ]
  rows << [
    make_cell(Spree.t(:signature, scope: [:invoices_and_documents, :pdf]), font_style: :bold),
    make_cell("\n\n\n\n\n\n\n")
  ]

  table(rows, column_widths: [280, 280], header: true, width: 560, cell_style: { padding: [4, 4] }) do
    column(0).style align: :right
  end

  font_size 9
end

# Footer for all pages
repeat :all do
  grid([12, 0], [12, 5]).bounding_box do
    stroke_line [0, 43], [560, 43]
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
