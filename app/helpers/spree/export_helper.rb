require 'builder'

module Spree

  module ExportHelper

    DATE_FORMAT = '%m/%d/%Y %H:%M'.freeze

    # rubocop:disable all
    def self.address(xml, order, type)
      name = "#{type.to_s.titleize}To"
      address = order.send("#{type}_address")

      xml.__send__(name) {
        xml.Name{ |xml| xml.cdata!(address.full_name.to_json) } 
        xml.Company{ |xml| xml.cdata!(address.company.to_json) } 

        if type == :ship
          xml.Address1{ |xml| xml.cdata!(address.address1.to_json) } 
          xml.Address2{ |xml| xml.cdata!(address.address2.to_json) } 
          xml.City{ |xml| xml.cdata!(address.city.to_json) } 
          xml.State{ |xml| xml.cdata!(address.state ? address.state.abbr : address.state_name.to_json) } 
          xml.PostalCode{ |xml| xml.cdata!(address.zipcode.to_json) } 
          xml.Country{ |xml| xml.cdata!(address.country.iso.to_json) } 
        end

        xml.Phone{ |xml| xml.cdata!(address.phone.to_json) } 
      }
    end
    # rubocop:enable all

  end

end



