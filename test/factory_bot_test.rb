require 'test_helper'

class FactoryBotTest < ActiveSupport::TestCase
  def test_factories
    FactoryBot.lint
  end
end
