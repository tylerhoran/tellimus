class Subscription < ActiveRecord::Base
  include Tellimus::Subscription

  belongs_to :user

end
