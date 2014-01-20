require 'prawnto'
require 'prawn-svg'
require 'ruby-progressbar'

class GenerateAndSaveCurrentInvoicesToDocuments < ActiveRecord::Migration
  def up
    migration_results = {
      not_updated_orders: [],
      not_updated_credited_orders: [],
      not_invoiced_orders: [],
      updated_credited_and_debited_orders: [],
      updated_and_credited_orders: [],
      orders_with_one_cent_adjustment: []
    }

    say('Disabling mail delivery')
    say('done', true) if Spree::Config.set(:enable_mail_delivery, false)

    if Spree::Order.where(state: 'cart').any?
      raise 'Cart orders found, run rake maintenance:clear_carts first'
    end

    say('Removing already generated invoices')
    Spree::Document.where(source_type: 'Spree::Order').where('document_file_name LIKE ?', 'invoice%.pdf').destroy_all
    say('done', true)

    say('Generate hard copies, credit invoice (if necessary), recalculate order (if necessary) and new invoices for all orders')
    orders = Spree::Order
    progress = ProgressBar.create(title: 'Orders', total: orders.count)

    orders.find_each(batch_size: 50) do |order|
      if order.invoice_number.present? && !order.completed_at.blank? && order.bill_address.present? && order.ship_address.present? && (order.payments.where("state NOT IN ('invalid', 'failed', 'void')").any? || order.allow_shipping_without_payment?)
        generate_hard_copy(order)

        if will_change_on_regeneration(order)
          generate_hard_copy(order, true)
          order.reload
          order = update_order(order)

          if order.payments.where("state NOT IN ('invalid', 'failed', 'void')").any? || order.allow_shipping_without_payment?
            order.send(:create_invoice, highest_order_number + 1)
            @highest_order_number += 1
            migration_results[:updated_credited_and_debited_orders] << order.number
          else
            migration_results[:updated_and_credited_orders] << order.number
          end
        else
          if order.payments.where("state NOT IN ('invalid', 'failed', 'void')").any? || order.allow_shipping_without_payment?
            order.send(:create_invoice, order.invoice_number)
            migration_results[:not_updated_orders] << order.number
          else
            generate_hard_copy(order, true)
            migration_results[:not_updated_credited_orders] << order.number
          end
        end
      else
        order.update!
        migration_results[:not_invoiced_orders] << order.number
      end

      progress.increment
    end
    say('done', true)

    say('Evaluating payment differences of 1 cent')
    orders = Spree::Order.where('payment_total > 0')
    progress = ProgressBar.create(title: 'Orders', total: orders.count)

    orders.each do |order|
      if [-0.01, 0.01].include?((order.total - order.payment_total).round(2).to_f)
        order.adjustments.create!(label: '1 cent correction', amount: - (order.total - order.payment_total).round(2).to_f).close!
        migration_results[:orders_with_one_cent_adjustment] << order.number
      end
      progress.increment
    end
    say('done', true)

    say('Enabling mail delivery')
    say('done', true) if Spree::Config.set(:enable_mail_delivery, true)

    say('Results:')
    migration_results.each do |k, v|
      say(k.to_s.humanize, true)
      say(v.inspect, true)
      say('---', true)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def highest_order_number
    @highest_order_number ||= [
      (Spree::Order.where('invoice_number IS NOT NULL').order('invoice_number DESC').pluck('invoice_number').first || 0),
      (Spree::Invoice.order('invoice_number DESC').pluck('invoice_number').first || 0)
    ].sort.last
  end

  def generate_hard_copy(order, credit = false)
    if credit
      template = File.read(Rails.root.join('app/views/spree/admin/orders/credit_invoice.pdf.prawn'))
      invoice_number = nil
    else
      template = File.read(Rails.root.join('app/views/spree/admin/orders/invoice.pdf.prawn'))
      invoice_number = order.invoice_number
    end

    if invoice_number.nil? || !invoice_number.present?
      invoice_number = highest_order_number + 1
      @highest_order_number += 1
    end

    pdf = Prawn::Document.new(page_size: 'A4', page_layout: :portrait, margin: 20)

    pdf.instance_eval do
      @order = order
      @invoice_number = invoice_number
      eval(template)
    end

    file = Tempfile.new([credit ? 'credit_invoice' : 'invoice', '.pdf'], encoding: 'ascii-8bit')
    file.write pdf.render
    file.close

    document = order.documents.build({
      name: "#{credit ? 'Credit Invoice' : 'Invoice'} #{invoice_number}",
      description: 'File generated and saved by migration for future reference.',
      document: File.new(file.path, 'r')
    })
    document.save!

    file.unlink
  end

  def will_change_on_regeneration(order)
    return true if order.adjustments.eligible.where("(label ILIKE ? OR label ILIKE ?) AND (originator_type IS NULL OR originator_type = '') AND (originator_id IS NULL OR originator_id = 0)", '%shipping%', '%btw%').any?
    return true if order.adjustments.eligible.where(originator_type: 'Spree::PromotionAction').any?

    if order.adjustments.eligible.tax.any? && order.adjustments.eligible.tax.map(&:amount).sum > 0 && (!order.tax_zone || order.tax_zone.tax_free? || order.tax_zone.tax_rates.none? || order.tax_zone.tax_rates.first.amount == 0)
      return true
    end

    if (order.adjustments.eligible.tax.none? || order.adjustments.eligible.tax.map(&:amount).sum == 0) && order.tax_zone && !order.tax_zone.tax_free? && order.tax_zone.tax_rates.any? && order.tax_zone.tax_rates.first.amount != 0
      return true
    end
  end

  def update_order(order)
    order.adjustments.where("(label ILIKE ? OR label ILIKE ?) AND (originator_type IS NULL OR originator_type = '') AND (originator_id IS NULL OR originator_id = 0)", '%shipping%', '%btw%').destroy_all

    order.update!

    order.create_tax_charge!

    order.adjustments.update_all state: 'closed'

    order.updater.update_payment_state
    order.shipments.each do |shipment|
      shipment.update!(order)
      shipment.finalize!
    end

    order.updater.update_shipment_state
    order.updater.run_hooks

    order
  end
end
