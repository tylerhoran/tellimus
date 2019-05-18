module Tellimus
  module ApplicationHelper

    def plan_price(plan)
      "#{number_to_currency(plan.price)}/#{plan_interval(plan)}"
    end

    def plan_interval(plan)
      interval = %w(month year week 6-month 3-month).include?(plan.interval) ? plan.interval.delete('-') : 'month'
      I18n.t("tellimus.plan_intervals.#{interval}")
    end

    # returns TRUE if the controller belongs to	Tellimus
    # false in all other cases, for convenience when executing filters
    # in the main application
    def tellimus_controller?
      is_a? Tellimus::ApplicationController
    end
  end
end
