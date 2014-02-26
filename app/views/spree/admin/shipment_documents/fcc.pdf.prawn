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
      make_cell(''),
      make_cell(Spree.t(:fcc, scope: [:invoices_and_documents, :pdf]), size: 12, font_style: :bold)
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
grid([3.05, 0], [9.6, 5]).bounding_box do
  font_size 12

  text Spree.t(:fcc_header, scope: [:invoices_and_documents, :pdf]), size: 14, align: :center, style: :bold

  move_down 8


end
