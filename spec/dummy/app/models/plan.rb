class Plan < ActiveRecord::Base

  include Tellimus::Plan
  belongs_to :user
  has_many :subscriptions

end
