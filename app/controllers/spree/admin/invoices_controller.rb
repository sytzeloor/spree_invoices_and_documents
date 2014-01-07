module Spree
  module Admin
    class InvoicesController < Spree::Admin::ResourceController
      prawnto prawn: { page_size: 'A4', margin: 20 }

      belongs_to 'spree/order', find_by: :number

      def show
        respond_to do |format|
          format.html
          format.pdf
        end
      end

      private

      def location_after_save
        admin_order_invoices_path(@invoice.order)
      end

      def collection_url
        if @invoice.order.present?
          admin_order_invoices_path(@invoice.order)
        else
          super
        end
      end

      def find_resource
        if parent && parent.respond_to?(controller_name)
          parent.send(controller_name).find(params[:id])
        else
          model_class.find(params[:id])
        end
      end
    end
  end
end
