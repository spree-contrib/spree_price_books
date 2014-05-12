module Spree
  module Admin
    ProductsController.class_eval do
      def variant_prices
        id = session[:current_price_book_id]
        session.delete(:current_price_book_id)

        @current_price_book = id.present? ? PriceBook.find(id) : PriceBook.default
        
        # need every variant/price(for the current price book) pair
        # I had to do this ridiculous sort to get the master first since the scope orders by position,
        # but for some reason the position is screwed up for master (it's not first)
        @variants = @product.variants_including_master.partition {|v| v.is_master?}.flatten
        
        @prices = {}
        
        @variants.each do |variant|
          @prices[variant.id] = variant.prices.detect {|price| price.price_book_id == @current_price_book.id} # possibly nil
        end
        
        @price_books    = PriceBook.order('priority')
        @default_price_book  = @price_books.detect {|pb| pb.default?}
      end
    end
  end
end
