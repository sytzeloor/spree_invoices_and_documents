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
      make_cell(Spree.t(:packaging_slip, scope: [:invoices_and_documents, :pdf]), size: 12, font_style: :bold),
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
      svg @shipment.barcode.to_svg, at: [0, 155], width: 200, height: 30
      text_box @shipment.tracking, at: [0, 80], width: 200, size: 8, align: :center
    end
  end

  if @shipment.order.respond_to?(:barcode)
    grid([1.15, 3], [3.15, 5]).bounding_box do
      svg @shipment.order.barcode.to_svg, at: [85, 155], width: 200, height: 30
      text_box "#{@shipment.order.number}-#{@shipment.order.checksum}", at: [85, 80], width: 200, size: 8, align: :center
    end
  end

  rows = []

  rows << [
    make_cell(Spree.t(:shipping_address, scope: [:invoices_and_documents, :pdf]), font_style: :bold),
    make_cell(Spree.t(:billing_address, scope: [:invoices_and_documents, :pdf]), font_style: :bold),
    make_cell(Spree.t(:shipping_method, scope: [:invoices_and_documents, :pdf]), font_style: :bold)
  ]

  grid([2.85, 0], [4, 5]).bounding_box do
    shipping_address = @shipment.order.ship_address
    billing_address = @shipment.order.bill_address

    shipping_address_label = []
    shipping_address_label << [shipping_address.firstname, shipping_address.lastname].compact.join(' ')
    shipping_address_label << shipping_address.company unless shipping_address.company.blank?
    shipping_address_label << shipping_address.address1
    shipping_address_label << shipping_address.address2 unless shipping_address.address2.blank?
    shipping_address_label << [shipping_address.city, shipping_address.state_text, shipping_address.zipcode.gsub(/ /, '')].compact.join(', ')
    shipping_address_label << shipping_address.country.name
    shipping_address_label << shipping_address.phone

    billing_address_label = []
    billing_address_label << [billing_address.firstname, billing_address.lastname].join(' ')
    billing_address_label << billing_address.company unless billing_address.company.blank?
    billing_address_label << billing_address.vat_number unless billing_address.vat_number.blank?
    billing_address_label << billing_address.address1
    billing_address_label << billing_address.address2 unless billing_address.address2.blank?
    billing_address_label << [billing_address.city, billing_address.state_text, billing_address.zipcode.gsub(/ /, '')].compact.join(' ')
    billing_address_label << billing_address.country.name

    rows << [
      make_cell(shipping_address_label.join("\n")),
      make_cell(billing_address_label.join("\n")),
      make_cell(@shipment.shipping_method.name, size: 20, align: :center, font_style: :bold, valign: :center)
    ]

    table(rows, column_widths: [200, 200, 160], header: true, width: 560, cell_style: { padding: [4, 4] })
  end

  stroke_line [0, 520], [560, 520]
end

# Inventory items
grid([5.05, 0], [9.6, 5]).bounding_box do
  rows = []

  rows << [
    make_cell(Spree.t(:sku, scope: [:invoices_and_documents, :pdf]), font_style: :bold),
    make_cell(Spree.t(:description, scope: [:invoices_and_documents, :pdf]), font_style: :bold),
    make_cell(Spree.t(:units, scope: [:invoices_and_documents, :pdf]), font_style: :bold),
  ]

  @shipment.manifest.each do |item|
    line_item = @shipment.order.find_line_item_by_variant(item.variant)

    rows << [
      make_cell(item.variant.sku),
      make_cell([item.variant.product.name, item.variant.option_values.empty? ? nil : "(#{item.variant.options_text})"].compact.join(' ')),
      make_cell("#{item.states.select { |state, count| %w(on_hand shipped ready).include?(state) }.map { |state, count| count }.sum} x"),
    ]
  end

  table(rows, column_widths: [80, 400, 80], header: true, width: 560, cell_style: { padding: [4, 4] })
end

# Footer for all pages
repeat :all do
  grid([10.5, 0], [10.5, 5]).bounding_box do
    stroke_line [0, 58], [560, 58]
  end

  # Special instructions
  grid([10.5, 0], [12, 3.5]).bounding_box do
    if @shipment.order.special_instructions
      text Spree.t(:customer_comments, scope: [:invoices_and_documents, :pdf]), style: :bold
      move_down 2
      text @shipment.order.special_instructions
      move_down 8
    end
  end

  # Packages and weight
  grid([10.5, 4], [11, 5]).bounding_box do
    rows = []

    rows << [
      make_cell(Spree.t(:weight, scope: [:invoices_and_documents, :pdf]), font_style: :bold),
      make_cell("#{@shipment.to_package.weight} #{Spree.t(:weight_label, scope: [:invoices_and_documents, :pdf])}")
    ]

    rows << [
      make_cell(Spree.t(:number_of_packages, scope: [:invoices_and_documents, :pdf]), font_style: :bold),
      make_cell(params[:packages] || '')
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
