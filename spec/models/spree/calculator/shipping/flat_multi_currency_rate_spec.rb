require 'spec_helper'

module Spree
  module Calculator::Shipping
    describe FlatMultiCurrencyRate do
      let!(:currency_rate) { create :currency_rate, currency: 'GBP', exchange_rate: 0.75 }
      let(:variant1) { build(:variant) }
      let(:variant2) { build(:variant) }
      let(:stock_location) { build(:stock_location) }

      subject { Calculator::Shipping::FlatMultiCurrencyRate.new(preferred_amount: 4.00) }

      context 'order for another currency' do
        let(:order) { create(:order, currency: 'GBP') }
        let(:line_item) { build(:line_item, order: order) }

        let(:package) { Stock::Package.new(stock_location, 
          [
            Stock::ContentItem.new(build(:inventory_unit, order: order, variant: variant1)),
            Stock::ContentItem.new(build(:inventory_unit, order: order, variant: variant2))
          ])
        }

        it 'always returns the same rate for base currency' do
          expect(subject.compute(package)).to eql 3.00
        end
      end

      context 'order for base currency' do
        let(:order) { build(:order, currency: Spree::Config[:currency]) }
        let(:line_item) { build(:line_item, order: order) }

        let(:package) { Stock::Package.new(stock_location, 
          [
            Stock::ContentItem.new(build(:inventory_unit, order: order, variant: variant1)),
            Stock::ContentItem.new(build(:inventory_unit, order: order, variant: variant2))
          ])
        }

        it 'always returns the same rate for base currency' do
          expect(subject.compute(package)).to eql 4.00
        end
      end

    end
  end
end
