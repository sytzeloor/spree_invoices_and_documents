module Spree
  module Admin
    class ShipmentDocumentsController < Spree::Admin::BaseController
      prawnto prawn: { page_size: 'A4', margin: 20 }

      def show
        @shipment = Spree::Shipment.find(params[:shipment_id])

        respond_to do |format|
          format.pdf { render params[:template] }
        end
      end

      private

      def model_class
        Spree::Shipment
      end
    end
  end
end
