Deface::Override.new(
  virtual_path: 'spree/admin/shared/_order_tabs',
  name: 'add_admin_order_tabs_documents_button',
  insert_bottom: '[data-hook="admin_order_tabs"]',
  partial: 'spree/admin/documents/order_tab',
  disabled: false
)
