Tellimus.setup do |config|
  config.subscriptions_owned_by = :<%= subscription_owner_model %>
  config.braintree_public_key = ENV['BRAINTREE_PUBLIC_KEY']
  config.braintree_private_key = ENV['BRAINTREE_PRIVATE_KEY']
  config.braintree_merchant_id = ENV['BRAINTREE_MERCHANT_ID']
  config.braintree_environment = ENV['BRAINTREE_ENVIRONMENT']

  # config.prorate = false # Default is true, set to false to disable prorating subscriptions
  # config.free_trial_length = 30

  # Specify layout you want to use for the subscription pages, default is application
  config.layout = 'application'

end
