module Spree
  class InvoiceAddress < ActiveRecord::Base
    attr_accessor :order

    belongs_to :invoice
    belongs_to :address

    validate :first_name, :last_name, presence: true, unless: :has_company?
    validate :company, presence: true, unless: :has_name?
    validate :address_1, :city, :zipcode, :country_name, presence: true

    set_callback :initialize, :after, :set_details

    def set_details
      return if (!order || !order.billing_address) && (!invoice || !invoice.order || !invoice.order.billing_address)

      self.address = (order || invoice.order).billing_address

      self.first_name   = address.firstname
      self.last_name    = address.lastname
      self.company      = address.company
      self.tax_id       = address.vat_number if address.respond_to?(:vat_number)
      self.address_1    = address.address1
      self.address_2    = address.address2
      self.city         = address.city
      self.zipcode      = address.zipcode
      self.state_name   = address.state ? address.state.name : address.state_name
      self.country_name = address.country.name
    end

    def has_name?
      first_name.present? || last_name.present?
    end

    def has_company?
      company.present?
    end
  end
end
