xml = Builder::XmlMarkup.new
xml.instruct!
xml.Orders(pages: (@shipments.total_count/50.0).ceil) {
  @shipments.each do |shipment|
    order = shipment.order

    xml.Order {
      xml.tag!("OrderID") { xml.cdata!(shipment.id.to_s) }
      xml.tag!("OrderNumber") { xml.cdata!(shipment.number.to_s) } # do not use shipment.order.number as this presents lookup issues
      xml.tag!("OrderDate") { xml.cdata!(order.completed_at.strftime(Spree::ExportHelper::DATE_FORMAT).to_s) }
      xml.tag!("OrderStatus") { xml.cdata!(shipment.state.to_s) }
      xml.tag!("LastModified") { xml.cdata!([order.completed_at, shipment.updated_at].max.strftime(Spree::ExportHelper::DATE_FORMAT).to_s) }
      xml.tag!("ShippingMethod") { xml.cdata!(shipment.shipping_method.try(:name).to_s) }
      xml.tag!("OrderTotal") { xml.cdata!(order.total.to_s) }
      xml.tag!("TaxAmount") { xml.cdata!(order.tax_total.to_s) }
      xml.tag!("ShippingAmount") { xml.cdata!(order.ship_total.to_s) }
      xml.tag!("CustomField1") { xml.cdata!(order.number.to_s) }

      xml.Customer {
        xml.tag!("CustomerCode") { xml.cdata!(order.email.slice(0, 50).to_s) }
        Spree::ExportHelper.address(xml, order, :bill)
        Spree::ExportHelper.address(xml, order, :ship)
      }
      xml.Items {
        shipment.line_items.each do |line|
          variant = line.variant
          xml.Item {
            xml.tag!("SKU") { xml.cdata!(variant.sku.to_s) }
            xml.tag!("Name") { xml.cdata!([variant.product.name, variant.options_text].join(' ').to_s) }
            xml.tag!("ImageUrl") { xml.cdata!(variant.images.first.try(:attachment).try(:url).to_s) }
            xml.tag!("Weight") { xml.cdata!(variant.weight.to_f.to_s) }
            xml.tag!("WeightUnits") { xml.cdata!(Spree::Config.shipstation_weight_units.to_s) }
            xml.tag!("Quantity") { xml.cdata!(line.quantity.to_s) }
            xml.tag!("UnitPrice") { xml.cdata!(line.price.to_s) }

            if variant.option_values.present?
              xml.Options {
                variant.option_values.each do |value|
                  xml.Option {
                    xml.tag!("Name") { xml.cdata!(value.option_type.presentation.to_s) }
                    xml.tag!("Value") { xml.cdata!(value.name.to_s) }
                  }
                end
              }
            end
          }
        end
      }
    }
  end
}
