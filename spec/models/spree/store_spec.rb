require 'spec_helper'

describe Spree::Store do
  let(:price_books) do
    [
      create(:price_book, currency: 'AUD'),
      create(:price_book, currency: 'USD'),
      create(:price_book, currency: 'DKK')
    ]
  end
  let(:store) { create(:store, price_books: price_books) }

  context 'supported currencies' do
    example 'finds all currencies from the stores price books' do
      expect(store.supported_currencies).to eq ['AUD', 'USD', 'DKK']
    end
  end
end
