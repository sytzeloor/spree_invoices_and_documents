class FixTaxAdjustments < ActiveRecord::Migration
  def up
    Spree::Config.set(:enable_mail_delivery, false)
    Spree::Adjustment.where("label ILIKE ? AND (originator_type IS NULL OR originator_type = '') AND (originator_id IS NULL OR originator_id = 0)", '%btw%').destroy_all
    Spree::Order.all.each do |order|
      order.update!
      order.reload
      if order.complete?
        order.create_tax_charge!

        order.adjustments.update_all state: 'closed'

        order.updater.update_payment_state
        order.shipments.each do |shipment|
          shipment.update!(order)
          shipment.finalize!
        end

        order.updater.update_shipment_state
        order.save
        order.updater.run_hooks
      end
    end
    Spree::Config.set(:enable_mail_delivery, true)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
