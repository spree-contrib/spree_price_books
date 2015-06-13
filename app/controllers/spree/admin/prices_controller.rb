module Spree
  module Admin
    class PricesController  < ResourceController
      belongs_to 'spree/product', find_by: :slug

      def update
        params[:variant].each_pair do |id, amount_hash|
          next if amount_hash[:amount].blank?
          variant_price(id).update_attributes(amount: amount_hash[:amount])
        end if params[:variant]

        redirect_to return_path
      end

      protected

      def variant_price(variant_id)
        current_price_book = Spree::PriceBook.find(params[:price_book_id])
        Spree::Price.where(
          variant_id: variant_id,
          price_book_id: current_price_book.id,
          currency: current_price_book.currency
        ).first_or_create
      end

      def return_path
        if !!session[:return_to_price_book]
          session.delete(:return_to_price_book)
          admin_price_book_path(params[:price_book_id])
        else
          session[:current_price_book_id] = params[:price_book_id]
          variant_prices_admin_product_path(params[:product_id])
        end
      end
    end
  end
end
