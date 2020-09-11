require 'builder'

module Spree

  module ExportHelper

    DATE_FORMAT = '%m/%d/%Y %H:%M'.freeze

    # rubocop:disable all
    def self.address(xml, order, type)
      name = "#{type.to_s.titleize}To"
      address = order.send("#{type}_address")

      xml.__send__(name) {
        xml.tag!("Name") { xml.cdata!(address.full_name.to_json) }
        xml.tag!("Company") { xml.cdata!(address.company.to_json) }

        if type == :ship
          xml.tag!("Address1") { xml.cdata!(address.address1.to_json) }
          xml.tag!("Address2") { xml.cdata!(address.address2.to_json) }
          xml.tag!("City") { xml.cdata!(address.city.to_json) }
          xml.tag!("State") { xml.cdata!(address.state ? address.state.abbr : address.state_name.to_json) }
          xml.tag!("PostalCode") { xml.cdata!(address.zipcode.to_json) }
          xml.tag!("Country") { xml.cdata!(address.country.iso.to_json) }
        end

        xml.tag!("Phone") { xml.cdata!(address.phone.to_json) }
      }
    end
    # rubocop:enable all

  end

end



