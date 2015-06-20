require 'spec_helper'

describe Spree::Order do
  context 'CurrencyUpdater' do
    context "when changing order currency" do
      let!(:line_item) { create(:line_item) }
      let!(:euro_price) {
        create(:price,
          variant: line_item.variant,
          amount: 8,
          currency: 'EUR',
          price_book: create(:store_price_book, currency: 'EUR', discount: true, priority: 1, stores: [Spree::Store.default])
        )
      }
      let!(:euro_list_price) {
        create(:price,
          variant: line_item.variant,
          amount: 18,
          currency: 'EUR',
          price_book: create(:store_price_book, currency: 'EUR', discount: false, priority: 0, stores: [Spree::Store.default])
        )
      }

      context "#homogenize_line_item_currencies" do
        it "succeeds without error" do
          expect { line_item.order.update_attributes!(currency: 'EUR') }.to_not raise_error
        end

        it "changes the line_item currencies" do
          expect { line_item.order.update_attributes!(currency: 'EUR') }.to change{ line_item.reload.currency }.from('USD').to('EUR')
        end

        it "changes the line_item amounts" do
          expect { line_item.order.update_attributes!(currency: 'EUR') }.to change{ line_item.reload.amount }.to(8)
        end

        it "changes the line_item list_price" do
          expect { line_item.order.update_attributes!(currency: 'EUR') }.to change{ line_item.reload.list_price }.to(18)
        end

        it "fails to change the order currency when no prices are available in that currency" do
          expect { line_item.order.update_attributes!(currency: 'CNY') }.to raise_error
        end

        it "calculates the item total in the order.currency" do
          expect { line_item.order.update_attributes!(currency: 'EUR') }.to change{ line_item.order.item_total }.to(8)
        end
      end
    end
  end
end
