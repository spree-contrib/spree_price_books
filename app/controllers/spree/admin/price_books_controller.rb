module Spree
  module Admin
    class PriceBooksController < Spree::Admin::ResourceController
      def add_products
        @price_book = Spree::PriceBook.find(params[:id])
        @products = if @price_book.products.count == 0
          Spree::Product.page(params[:page])
        else
          Spree::Product.where(
            "id NOT IN (?)",
            @price_book.products.pluck(:id)
          ).page(params[:page])
        end
      end

      def edit_product_price
        session[:current_price_book_id] = params[:price_book_id]
        session[:return_to_price_book] = true
        redirect_to variant_prices_admin_product_path(params[:product_id])
      end

      def products
        @price_book = Spree::PriceBook.find(params[:id])
        params[:products].keys.each { |id| @price_book.add_product_by_id(id) }
        redirect_to spree.admin_price_book_path(@price_book)
      end

      def remove_product
        @price_book = Spree::PriceBook.find(params[:price_book_id])
        @product = Spree::Product.find(params[:product_id])
        variant_ids = @product.variants_including_master.pluck(:id)

        @price_book.prices.where(variant_id: variant_ids).destroy_all
        redirect_to :back
      end

      def show
        @products = @price_book.products.page(params[:page])
      end

      def sort
        store = Spree::Store.find(params[:store_id])
        params[:store_price_book_id].each_with_index do |id, index|
          book = store.store_price_books.where(price_book_id: id).first
          book.update_attribute(:priority, index) if book.present?
        end
        render nothing: true
      end
    end
  end
end
