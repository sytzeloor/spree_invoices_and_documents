module Spree
  class ShipmentObserver < ActiveRecord::Observer
    def after_transition(shipment, transition)
      return unless transition.to == 'pending' && !shipment.tracking.present?

      message = Spree::ShipmentDocumentsMailer.notify(shipment)
      message.deliver unless message.nil?
    end
  end
end
