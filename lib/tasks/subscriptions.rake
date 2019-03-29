namespace :subscriptions do
  desc 'Renew any subscriptions that should be billed on a given date'
  task :renew, [:year, :month, :day] => [:environment] do |_t, args|
    year = args.fetch(:year).to_i
    month = args.fetch(:month).to_i
    day = args.fetch(:day).to_i

    date = Date.new(year, month, day)

    Rails.logger.info "Renewing subscriptions on #{date}..."
    results = ::Subscriptions::Renewer.new.call(date)

    results.each do |subscription_id, is_successful|
      if is_successful
        Rails.logger.info "Subscription ##{subscription_id} has been renewed successfully on #{date}."
      else
        Rails.logger.warn "Payment for subscription ##{subscription_id} failed on #{date}."
      end
    end

    Rails.logger.info 'Done.'
  end
end
