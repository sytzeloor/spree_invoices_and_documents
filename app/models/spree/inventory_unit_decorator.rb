module Spree
  InventoryUnit.class_eval do
    alias_method :original_variant, :variant

    def variant
      Spree::Variant.with_deleted.find(variant_id)
    end
  end
end
