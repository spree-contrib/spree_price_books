module Spree
  module Admin
    module PriceBooksHelper
      def pb_currency_options(selected = Spree::Config[:currency])
        currencies = ::Money::Currency.table.map do |code, details|
          iso = details[:iso_code]
          [iso, "#{details[:name]} (#{iso})"]
        end
        options_from_collection_for_select(currencies, :first, :last, selected)
      end
    end
  end
end
