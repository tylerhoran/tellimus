class Plan < ActiveRecord::Base

  include Koudoku::Plan
  belongs_to :customer
  has_many :subscriptions

end
