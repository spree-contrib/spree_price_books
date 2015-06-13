require 'spec_helper'

describe "Price Books", js: true do

  after do
    Spree::Config[:currency] = 'USD'
  end

  before do
    Spree::Config[:allow_currency_change] = true
    Spree::Config[:show_currency_selector] = true
    Spree::Config[:supported_currencies] = 'GBP,USD'
    Spree::Config[:currency] = 'GBP'
  end

  let!(:default) { create(:default_price_book, currency: 'GBP') }
  let!(:taxon) { create(:taxon) }
  let!(:store) {
    store = create :store, default: true, default_currency: 'GBP'
    store.price_books << default
    store.price_books << price_book_2
    store.taxonomies  << taxon.taxonomy
    store
  }
  let!(:product) {
    p = create(:product, taxons: [taxon], stores: [store])
    store.products << p # association must be set both ways...
    p
  }
  let(:price_book_2) { create(:factored_price_book, currency: 'USD', parent: default) }

  context 'when only list books active' do
    before do
      ApplicationController.any_instance.stub(:current_store) { store.reload }
    end

    it 'displays proper price when currency changed' do
      visit spree.nested_taxons_path(taxon.permalink)
      within '#products span.price' do
        expect(page).to have_content('£19.99')
      end

      select 'USD', from: 'currency'
      wait_for_ajax

      within '#products span.price' do
        expect(page).to have_content('$49.98')
      end
    end
  end

  context 'when discount books active' do
    before do
      price_book_3 = create(:factored_price_book, currency: 'USD', discount: true, parent: price_book_2, price_adjustment_factor: 0.5)
      store.price_books << price_book_3
      ApplicationController.any_instance.stub(:current_store) { store.reload }
    end

    it 'should display list and sale price' do
      visit spree.nested_taxons_path(taxon.permalink)
      within '#products span.price' do
        expect(page).to have_content('£19.99')
      end

      select 'USD', from: 'currency'
      wait_for_ajax

      # On products#index page
      within '#products div.product-list-item' do
        expect(page).to have_content('$24.99')
        find('a').click
      end
      # On products#show page
      within '#product-price' do
        expect(page).to have_content('$24.99')
      end
      click_button "add-to-cart-button"
      # On cart page
      within '#cart' do
        expect(page).to have_content('$24.99')
      end
    end
  end

end
