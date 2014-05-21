namespace :price_books do
  desc "Set default currency rates from Google."
  task :currency_rates => :environment do
    # See https://github.com/RubyMoney/google_currency for more info.
    #
    # (optional)
    # set the seconds after than the current rates are automatically expired
    # by default, they never expire
    Money::Bank::GoogleCurrency.ttl_in_seconds = 86400
    # set default bank to instance of GoogleCurrency
    Money.default_bank = Money::Bank::GoogleCurrency.new
    Money::Currency.all.each do |currency|
      # Limit to only major currencies, which have priority below 100.
      next if currency.priority >= 100
      begin
        rate = Money.default_bank.get_rate(Spree::CurrencyRate.default.currency, currency.iso_code)
        if cr = Spree::CurrencyRate.find_or_create_by(base_currency: Spree::CurrencyRate.default.currency, currency: currency.iso_code, default: (Spree::Config[:currency] == currency.iso_code))
          cr.update_attribute :exchange_rate, rate
        end
      rescue Money::Bank::UnknownRate # Google doesn't track this currency.
      rescue Money::Bank::GoogleCurrencyFetchError => ex
        puts currency.inspect
        puts ex.message
        puts ex.backtrace
      end
    end
  end
end
