Tellimus.setup do |config|
  config.subscriptions_owned_by = :user
  config.braintree_public_key = "fake"
  config.braintree_private_key = "fake"
  config.braintree_merchant_id = "fake"
  config.braintree_environment = "sandbox"

  # config.prorate = false # Default is true, set to false to disable prorating subscriptions
  # config.free_trial_length = 30

  # Specify layout you want to use for the subscription pages, default is application
  config.layout = 'application'

end
