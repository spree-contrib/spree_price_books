FactoryGirl.define do
  # Define your Spree extensions Factories within this file to enable applications, and other extensions to use and override them.
  #
  # Example adding this to your spec_helper will load these Factories for use:
  # require 'spree_price_books/factories'


  factory :currency_rate, class: 'Spree::CurrencyRate' do
    base_currency { Spree::Config[:currency] }
    currency { Spree::Config[:currency] }
    exchange_rate 1

    factory :default_currency_rate do
      default true
    end
  end

  factory :price_book, :class => 'Spree::PriceBook' do
    currency { Spree::Config[:currency] }
    name 'Generic Price Book'

    factory :active_price_book do
      active_from 1.month.ago
      active_to 1.month.from_now

      factory :default_price_book do
        default true
        name 'Default'
      end

      factory :explicit_price_book do
        name 'Explicit'
      end

      factory :factored_price_book do
        name 'Factored'
        parent { Spree::PriceBook.default }
        price_adjustment_factor 2.5
        priority 10
      end

      factory :store_price_book do
        after(:create) { |book| create(:store, price_books: [book]) unless book.stores.present? }
      end

      factory :explicit_price_book_with_products do
        name 'Explicit'
        after(:create) do |book|
          book.add_product(create(:product, price: 123)) if book.products.empty?
        end
      end

    end
  end

  factory :spree_store_price_book, :class => 'Spree::StorePriceBook' do
    price_book
    store
    active false
    priority 1
  end

end
