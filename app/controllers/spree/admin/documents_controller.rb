module Spree
  module Admin
    class DocumentsController < Spree::Admin::ResourceController
      belongs_to 'spree/order', find_by: :number

      private

      def location_after_save
        polymorphic_path([:admin, @document.source, :documents])
      end

      def collection_url
        if @document.source.present?
          polymorphic_path([:admin, @document.source, :documents])
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
