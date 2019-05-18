class Subscription < ActiveRecord::Base
  include Koudoku::Subscription

  belongs_to :customer

end
