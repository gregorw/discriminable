# frozen_string_literal: true

class Test < Minitest::Test
  def teardown
    ActiveRecord::Base.descendants.reject do |klass|
      klass.name.split("::").first == "ActiveRecord"
    end.map(&:delete_all)
  end
end
