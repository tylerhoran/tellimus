class Subscription < ActiveRecord::Base
  include Tellimus::Subscription

  <%= "attr_accessible :credit_card_token" if Rails::VERSION::MAJOR == 3 %>
  belongs_to :<%= subscription_owner_model %>

end
