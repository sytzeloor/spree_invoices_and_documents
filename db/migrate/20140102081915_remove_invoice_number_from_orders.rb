class RemoveInvoiceNumberFromOrders < ActiveRecord::Migration
  def up
    remove_column :spree_orders, :invoice_number
  end

  def down
    add_column :spree_orders, :invoice_number, :integer
  end
end
