class CreateInvoiceAddresses < ActiveRecord::Migration
  def change
    create_table :spree_invoice_addresses do |t|
      t.references :address, index: true
      t.string :first_name
      t.string :last_name
      t.string :company
      t.string :tax_id
      t.string :address_1
      t.string :address_2
      t.string :city
      t.string :zipcode
      t.string :state_name
      t.string :country_name

      t.timestamps
    end
  end
end
