module Tellimus::Subscription
  extend ActiveSupport::Concern

  included do

    # We don't store these one-time use tokens, but this is what Braintree provides
    # client-side after storing the credit card information.
    attr_accessor :payment_method_nonce

    belongs_to :plan, optional: true

    # update details.
    before_save :processing!
    before_destroy :cancelling!

    def processing!
      # if their package level has changed ..
      if changing_plans?

        prepare_for_plan_change

        # and a subscription exists in stripe ..
        if braintree_id.present?

          # if a new plan has been selected
          if self.plan.present?

            # Record the new plan pricing.
            self.current_price = self.plan.price

            prepare_for_downgrade if downgrading?
            prepare_for_upgrade if upgrading?

            # update the package level with braintree.
            Tellimus.gateway.subscription.update(
              self.braintree_id,
              plan_id: self.plan.braintree_id,
              price: self.plan.price,
              options: {
                prorate_charges: true,
              }
            )

            finalize_downgrade! if downgrading?
            finalize_upgrade! if upgrading?

          # if no plan has been selected.
          else

            prepare_for_cancelation

            # Remove the current pricing.
            self.current_price = nil

            # delete the subscription.
            Tellimus.gateway.subscription.cancel(self.braintree_id)

            finalize_cancelation!

          end

        # when customer DOES NOT exist in braintree ..
        else

          # if a new plan has been selected
          if self.plan.present?

            # Record the new plan pricing.
            self.current_price = self.plan.price

            prepare_for_new_subscription
            prepare_for_upgrade
            begin
              raise Tellimus::NilCardToken, "No card token received. Check for JavaScript errors breaking Braintree.js on the previous page." unless payment_method_nonce.present?
              customer_attributes = {
                email: subscription_owner_email,
                payment_method_nonce: payment_method_nonce
              }

              # create a customer at that package level.
              result = Tellimus.gateway.customer.create(customer_attributes)
              unless result.success?
                errors[:base] << result.errors
                card_was_declined
                return false
              end

              finalize_new_customer!(result.customer.id, plan.price)
              payment_method = result.customer.payment_methods.last

              subscription_result = Tellimus.gateway.subscription.create(
                payment_method_token: payment_method.token,
                plan_id: self.plan.braintree_id
              )

              unless subscription_result.success?
                errors[:base] << subscription.errors
                card_was_declined
                return false
              end
            # store the customer id.
            self.braintree_customer_id = result.customer.id
            self.braintree_id = subscription_result.subscription.id

            if payment_method.class == Braintree::PayPalAccount
              self.payment_signature = payment_method.email
              self.payment_type = "Paypal"
            else
              self.payment_signature = payment_method.last_4
              self.payment_type = payment_method.card_type
            end

            finalize_new_subscription!
            finalize_upgrade!
            rescue StandardError => e
              errors[:base] << e
              return false
            end
          else

            # This should never happen.

            self.plan_id = nil

            # Remove any plan pricing.
            self.current_price = nil

          end

        end

        finalize_plan_change!

      # if they're updating their credit card details.
      elsif self.payment_method_nonce.present?

        prepare_for_card_update

        # fetch the customer.
        customer = Tellimus.gateway.customer.find(self.braintree_customer_id)
        payment_method_response = Tellimus.gateway.payment_method.create(
          :customer_id => self.braintree_customer_id,
          :payment_method_nonce => self.payment_method_nonce
        )
        subscription_response = Tellimus.gateway.subscription.update(
          self.braintree_id,
          payment_method_token: payment_method_response.payment_method.token,
        )

        unless subscription_response.success?
          errors[:base] << subscription_response.errors
          card_was_declined
          return false
        end

        payment_method_token = subscription_response.subscription.payment_method_token
        payment_method = Tellimus.gateway.payment_method.find(payment_method_token)
        if payment_method.class == Braintree::PayPalAccount
          self.payment_signature = payment_method.email
          self.payment_type = "Paypal"
        else
          self.payment_signature = payment_method.last_4
          self.payment_type = payment_method.card_type
        end


        finalize_card_update!

      end
    end
  end

  def cancelling!
    Tellimus.gateway.subscription.cancel(self.braintree_id)
  end

  def describe_difference(plan_to_describe)
    if plan.nil?
      if persisted?
        I18n.t('tellimus.plan_difference.upgrade')
      else
        if Tellimus.free_trial?
          I18n.t('tellimus.plan_difference.start_trial')
        else
          I18n.t('tellimus.plan_difference.upgrade')
        end
      end
    else
      if plan_to_describe.is_upgrade_from?(plan)
        I18n.t('tellimus.plan_difference.upgrade')
      else
        I18n.t('tellimus.plan_difference.downgrade')
      end
    end
  end

  # Pretty sure this wouldn't conflict with anything someone would put in their model
  def subscription_owner
    # Return whatever we belong to.
    # If this object doesn't respond to 'name', please update owner_description.
    send Tellimus.subscriptions_owned_by
  end

  def subscription_owner=(owner)
    # e.g. @subscription.user = @owner
    send Tellimus.owner_assignment_sym, owner
  end

  def subscription_owner_description
    # assuming owner responds to name.
    # we should check for whether it responds to this or not.
    "#{subscription_owner.try(:name) || subscription_owner.try(:id)}"
  end

  def subscription_owner_email
    "#{subscription_owner.try(:email)}"
  end

  def changing_plans?
    plan_id_changed?
  end

  def downgrading?
    plan.present? and plan_id_was.present? and plan_id_was > self.plan_id
  end

  def upgrading?
    (plan_id_was.present? and plan_id_was < plan_id) or plan_id_was.nil?
  end

  # Template methods.
  def prepare_for_plan_change
  end

  def prepare_for_new_subscription
  end

  def prepare_for_upgrade
  end

  def prepare_for_downgrade
  end

  def prepare_for_cancelation
  end

  def prepare_for_card_update
  end

  def finalize_plan_change!
  end

  def finalize_new_subscription!
  end

  def finalize_new_customer!(customer_id, amount)
  end

  def finalize_upgrade!
  end

  def finalize_downgrade!
  end

  def finalize_cancelation!
  end

  def finalize_card_update!
  end

  def card_was_declined
  end

  # stripe web-hook callbacks.
  def payment_succeeded(amount)
  end

  def charge_failed
  end

  def charge_disputed
  end

end
