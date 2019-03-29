namespace :subscriptions do
  desc 'Renew any subscriptions that should be billed on a given date'
  task :renew, [:year, :month, :day] => [:environment] do |_t, args|
    year = args.fetch(:year).to_i
    month = args.fetch(:month).to_i
    day = args.fetch(:day).to_i

    date = Date.new(year, month, day)
    ::Subscriptions::Renewer.new.call(date)
  end
end
