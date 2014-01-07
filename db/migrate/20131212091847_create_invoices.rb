class CreateInvoices < ActiveRecord::Migration
  def change
    create_table :spree_invoices do |t|
      t.references :order, index: true
      t.references :invoice_address, index: true
      t.integer :invoice_number
      t.string :order_reference
      t.date :invoice_date
      t.decimal :tax_rate, precision: 8, scale: 5
      t.decimal :tax_total, precision: 10, scale: 2, default: 0.0
      t.decimal :item_total, precision: 10, scale: 2, default: 0.0
      t.decimal :invoice_total, precision: 10, scale: 2, default: 0.0
      t.boolean :is_credit, default: false
      t.text :comments
      t.text :customer_comments

      t.timestamps
    end
  end
end
