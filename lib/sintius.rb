require "tellimus/engine"
require "tellimus/errors"
require "generators/tellimus/install_generator"
require "generators/tellimus/views_generator"

module Tellimus
  mattr_accessor :subscriptions_owned_by
  @@subscriptions_owned_by = nil

  mattr_accessor :subscriptions_owned_through
  @@subscriptions_owned_through = nil

  def self.subscriptions_owned_through_or_by
    @@subscriptions_owned_through || @@subscriptions_owned_by
  end

  mattr_accessor :braintree_public_key
  @@braintree_public_key = nil

  mattr_accessor :braintree_private_key
  @@braintree_private_key = nil

  mattr_accessor :braintree_merchant_id
  @@braintree_merchant_id = nil

  mattr_accessor :braintree_environment
  @@braintree_environment = nil

  mattr_accessor :free_trial_length
  @@free_trial_length = nil

  mattr_accessor :prorate
  @@prorate = true


  @@layout = nil

  def self.layout
    @@layout || 'application'
  end

  def self.layout=(layout)
    @@layout = layout
  end

  def self.setup
    yield self
  end

  def self.gateway
    Braintree::Gateway.new(
      environment: braintree_environment,
      merchant_id: braintree_merchant_id,
      public_key: braintree_public_key,
      private_key: braintree_private_key
    )
  end

  # e.g. :users
  def self.owner_resource
    subscriptions_owned_by.to_s.pluralize.to_sym
  end

  # e.g. :user_id
  def self.owner_id_sym
    :"#{Tellimus.subscriptions_owned_by}_id"
  end

  # e.g. :user=
  def self.owner_assignment_sym
    :"#{Tellimus.subscriptions_owned_by}="
  end

  # e.g. User
  def self.owner_class
    Tellimus.subscriptions_owned_by.to_s.classify.constantize
  end

  def self.free_trial?
    free_trial_length.to_i > 0
  end

end
