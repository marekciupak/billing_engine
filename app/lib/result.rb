class Result
  def initialize(is_successful, data: nil, errors: nil)
    @is_successful = is_successful
    @data = data
    @errors = errors
  end

  attr_reader :data, :errors

  def success?
    @is_successful
  end
end
