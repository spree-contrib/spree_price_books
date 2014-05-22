require 'spec_helper'

module Spree
  module Calculator::Shipping
    describe FlatMultiCurrencyRate do
      let!(:currency_rate) { create :currency_rate, currency: 'GBP', exchange_rate: 0.75 }
      let(:variant1) { build(:variant) }
      let(:variant2) { build(:variant) }

      subject { Calculator::Shipping::FlatMultiCurrencyRate.new(preferred_amount: 4.00) }

      context 'order for another currency' do
        let(:package) do
          Stock::Package.new(
            build(:stock_location),
            mock_model(Order, currency: 'GBP'),
            [
              Stock::Package::ContentItem.new(variant1, 2),
              Stock::Package::ContentItem.new(variant2, 1)
            ]
          )
        end

        it 'always returns the same rate for base currency' do
          expect(subject.compute(package)).to eql 3.00
        end
      end

      context 'order for base currency' do
        let(:package) do
          Stock::Package.new(
            build(:stock_location),
            mock_model(Order, currency: Spree::Config[:currency]),
            [
              Stock::Package::ContentItem.new(variant1, 2),
              Stock::Package::ContentItem.new(variant2, 1)
            ]
          )
        end

        it 'always returns the same rate for base currency' do
          expect(subject.compute(package)).to eql 4.00
        end
      end

    end
  end
end
