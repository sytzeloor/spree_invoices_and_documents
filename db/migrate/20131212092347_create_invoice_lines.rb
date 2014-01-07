class CreateInvoiceLines < ActiveRecord::Migration
  def change
    create_table :spree_invoice_lines do |t|
      t.references :invoice, index: true
      t.references :reference, polymorphic: true, index: true
      t.integer :order, default: 1
      t.string :sku
      t.string :description
      t.decimal :unit_price, precision: 10, scale: 2, default: 0.0
      t.integer :units, default: 1
      t.boolean :taxable, default: true
      t.boolean :tax_included, default: false

      t.timestamps
    end
  end
end
