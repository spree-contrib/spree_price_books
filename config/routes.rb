Spree::Core::Engine.routes.draw do

  namespace :admin do
    resources :currency_rates
    resources :price_books do
      resources :products, only: [] do
        get :remove_product, controller:'price_books'
        get :edit_product_price, controller:'price_books'
      end
      member do
        get :add_products
        patch :products
      end
    end
    resources :products do
      member do
        get :variant_prices
      end
    end
    resources :stores do
      resources :price_books do
        collection do
          post :sort
        end
      end
    end
    put 'update_variants_prices', to: 'prices#update'
  end

end
