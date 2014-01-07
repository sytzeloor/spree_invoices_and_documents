require 'digest/sha1'
require 'barby/barcode/code_128'

module Spree
  Shipment.class_eval do
    # Barcodes
    include HasBarcode

    has_barcode :barcode,
      outputter: :svg,
      type: Barby::Code128A,
      value: Proc.new { |shipment| shipment.tracking }
  end
end
