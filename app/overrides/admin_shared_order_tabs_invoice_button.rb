Deface::Override.new(
  virtual_path: 'spree/admin/shared/_order_tabs',
  name: 'add_admin_order_tabs_invoice_button',
  insert_bottom: '[data-hook="admin_order_tabs"]',
  partial: 'spree/admin/invoices/order_tab',
  disabled: false
)
