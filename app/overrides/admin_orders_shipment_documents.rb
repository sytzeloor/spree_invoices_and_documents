Deface::Override.new(
  virtual_path: 'spree/admin/orders/_shipment',
  name: 'add_admin_orders_shipment_documents',
  insert_after: '[data-hook="stock-contents"]',
  partial: 'spree/admin/documents/shipment',
  disabled: false
)
