xml = Builder::XmlMarkup.new
xml.instruct!
xml.Orders(pages: (@shipments.total_count/50.0).ceil) {
  @shipments.each do |shipment|
    order = shipment.order

    xml.Order {
      xml.OrderID{ |xml| xml.cdata!(shipment.id.to_json) }
      xml.OrderNumber{ |xml| xml.cdata!(shipment.number.to_json) }  # do not use shipment.order.number as this presents lookup issues
      xml.OrderDate{ |xml| xml.cdata!(order.completed_at.strftime(Spree::ExportHelper::DATE_FORMAT).to_json) } 
      xml.OrderStatus{ |xml| xml.cdata!(shipment.state.to_json) } 
      xml.LastModified{ |xml| xml.cdata!([order.completed_at, shipment.updated_at].max.strftime(Spree::ExportHelper::DATE_FORMAT).to_json) } 
      xml.ShippingMethod{ |xml| xml.cdata!(shipment.shipping_method.try(:name).to_json) } 
      xml.OrderTotal{ |xml| xml.cdata!(order.total.to_json) } 
      xml.TaxAmount{ |xml| xml.cdata!(order.tax_total.to_json) } 
      xml.ShippingAmount{ |xml| xml.cdata!(order.ship_total.to_json) } 
      xml.CustomField1{ |xml| xml.cdata!(order.number.to_json) } 

      xml.Customer {
        xml.CustomerCode{ |xml| xml.cdata!(order.email.slice(0, 50).to_json) } 
        Spree::ExportHelper.address(xml, order, :bill)
        Spree::ExportHelper.address(xml, order, :ship)
      }
      xml.Items {
        shipment.line_items.each do |line|
          variant = line.variant
          xml.Item {
            xml.SKU{ |xml| xml.cdata!(variant.sku.to_json) } 
            xml.Name{ |xml| xml.cdata!([variant.product.name, variant.options_text].join(' ').to_json) } 
            xml.ImageUrl{ |xml| xml.cdata!(variant.images.first.try(:attachment).try(:url).to_json) } 
            xml.Weight{ |xml| xml.cdata!(variant.weight.to_f.to_json) } 
            xml.WeightUnits{ |xml| xml.cdata!(Spree::Config.shipstation_weight_units.to_json) } 
            xml.Quantity{ |xml| xml.cdata!(line.quantity.to_json) } 
            xml.UnitPrice{ |xml| xml.cdata!(line.price.to_json) } 

            if variant.option_values.present?
              xml.Options {
                variant.option_values.each do |value|
                  xml.Option {
                    xml.Name{ |xml| xml.cdata!(value.option_type.presentation.to_json) } 
                    xml.Value{ |xml| xml.cdata!(value.name.to_json) } 
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
