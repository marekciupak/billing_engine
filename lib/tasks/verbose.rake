desc 'Switch rails logger to stdout'
task verbose: [:environment] do
  Rails.logger = Logger.new(STDOUT)
end
