namespace :price_books do
  desc "Set default currency rates from Google."
  task :currency_rates => :environment do
    # See https://github.com/RubyMoney/google_currency for more info.
    #
    # (optional)
    # set the seconds after than the current rates are automatically expired
    # by default, they never expire
    oxr = Money::Bank::OpenExchangeRatesBank.new
    oxr.app_id = Rails.application.config.openExchangeRate[:appId]
    oxr.update_rates
    oxr.cache = 'tmp/cache.json'
    oxr.ttl_in_seconds = 86400
    oxr.source = Spree::CurrencyRate.default.currency
    Money.default_bank = oxr

    Spree::Config[:supported_currencies].split(',').each do |currencyCode|
      currency = Money::Currency.new(currencyCode)
      begin
        rate = Money.default_bank.get_rate(Spree::CurrencyRate.default.currency, currency)
        if cr = Spree::CurrencyRate.find_or_create_by(base_currency: Spree::CurrencyRate.default.currency, currency: currency.iso_code, default: (Spree::Config[:currency] == currency.iso_code))
          cr.update_attribute :exchange_rate, rate
        end
      rescue Exception => ex
        puts currency.inspect
        puts ex.message
        puts ex.backtrace
      end
    end
  end
end
