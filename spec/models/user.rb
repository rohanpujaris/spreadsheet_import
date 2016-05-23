class User < ActiveRecord::Base
  validates :name, presence: true

  before_validation :callback_method
  before_save :callback_method
  after_save :callback_method
  around_save :around_callback_method

  before_create :callback_method
  after_create :callback_method
  around_create :around_callback_method

  before_update :callback_method
  after_update :callback_method
  around_update :around_callback_method

  def callback_method; end

  def around_callback_method
    yield
  end
end
