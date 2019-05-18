# Tellimus

Robust subscription support for Ruby on Rails apps using [Braintree](https://braintreepayments.com), including out-of-the-box pricing pages, payment pages, and  subscription management for your customers. This is a fork of [Koudoku](https://github.com/andrewculver/koudoku) specifically for Braintree.

## Installation

Include the following in your `Gemfile`:

```ruby
    gem 'tellimus'
```

After running `bundle install`, you can run a Rails generator to do the rest. Before installing, the model you'd like to have own subscriptions must already exist. (In many cases this will be `user`. It may also be something like `company`, etc.)

```ruby
    rails g tellimus:install user
    rake db:migrate
```

Add the following to `app/views/layouts/application.html.erb` before your `<head>` tag closes:

```ruby
    <%= yield :tellimus %>
```

(This allows us to inject a Braintree `<script>` tag in the correct place. If you don't, the payment form will not work.)

After installing, you'll need to add some subscription plans. (You can see an explanation of each of the attributes in the table below.)

**Note:** You need to create the plans in your [Braintree Dashboard](https://braintreepayments.com) separately.

```ruby
    Plan.create({
      name: 'Personal',
      price: 10.00,
      interval: 'month',
      braintree_id: '1',
      features: ['1 Project', '1 Page', '1 User', '1 Organization'].join("\n\n"),
      display_order: 1
    })

    Plan.create({
      name: 'Team',
      highlight: true, # This highlights the plan on the pricing page.
      price: 30.00,
      interval: 'month',
      braintree_id: '2',
      features: ['3 Projects', '3 Pages', '3 Users', '3 Organizations'].join("\n\n"),
      display_order: 2
    })

    Plan.create({
      name: 'Enterprise',
      price: 100.00,
      interval: 'month',
      braintree_id: '3',
      features: ['10 Projects', '10 Pages', '10 Users', '10 Organizations'].join("\n\n"),
      display_order: 3
    })
```

To help you understand the attributes:

| Attribute       | Type    | Function |
| --------------- | ------- | -------- |
| `name`          | string  | Name for the plan to be presented to customers. |
| `price`         | float   | Price per billing cycle. |
| `interval`      | string  | *Optional.* What is the billing cycle? Valid options are `month`, `year`, `week`, `3-month`, `6-month`. Defaults to `month`. |
| `braintree_id`     | string  | The Plan ID in Braintree. |
| `features`      | string  | A list of features. Supports Markdown syntax. |
| `display_order` | integer | Order in which to display plans. |
| `highlight`     | boolean | *Optional.* Whether to highlight the plan on the pricing page. |

The only view installed locally into your app by default is the `koudoku/subscriptions/_social_proof.html.erb` partial which is displayed alongside the pricing table. It's designed as a placeholder where you can provide quotes about your product from customers that could positively influence your visitors.

### Configuring Braintree API Keys

You can supply your publishable and secret API keys in `config/initializers/tellimus.rb`. However, by default it will use the `BRAINTREE_PUBLISHABLE_KEY` and `BRAINTREE_SECRET_KEY` shell environment variables. This encourages people to keep these API keys out of version control. You may want to rename these environment variables to be more application specific.

In a bash shell, you can set them in `~/.bash_profile` like so:

```bash
    export BRAINTREE_PUBLISHABLE_KEY=pk_0CJwDH9sdh98f79FDHDOjdiOxQob0
    export BRAINTREE_SECRET_KEY=sk_0CJwFDIUshdfh97JDJOjZ5OIDjOCH
```

(Reload your terminal for these settings to take effect.)

On Heroku you accomplish this same effect with [Config Vars](https://devcenter.heroku.com/articles/config-vars):

```bash
    heroku config:add BRAINTREE_PUBLISHABLE_KEY=pk_0CJwDH9sdh98f79FDHDOjdiOxQob0
    heroku config:add BRAINTREE_SECRET_KEY=sk_0CJwFDIUshdfh97JDJOjZ5OIDjOCH
```

## User-Facing Subscription Management

By default a `pricing_path` route is defined which you can link to in order to show visitors a pricing table. If a user is signed in, this pricing table will take into account their current plan. For example, you can link to this page like so:

```ruby
    <%= link_to 'Pricing', main_app.pricing_path %>
```

(Note: Tellimus uses the application layout, so it's important that application paths referenced in that layout are prefixed with "`main_app.`" like you see above or Rails will try to look the paths up in the Tellimus engine instead of your application.)

Existing users can view available plans, select a plan, enter credit card details, review their subscription, change plans, and cancel at the following route:

```ruby
    tellimus.owner_subscriptions_path(@user)
```

In these paths, `owner` refers to `User` by default, or whatever model has been configured to be the owner of the `Subscription` model.

A number of views are provided by default. To customize the views, use the following generator:

```ruby
    rails g tellimus:views
```

### Pricing Table

Tellimus ships with a stock pricing table. By default it depends on Twitter Bootstrap, but also has some additional styles required. In order to import these styles, add the following to your `app/assets/stylesheets/application.css`:

```css
    *= require 'tellimus/pricing-table'
```

Or, if you've replaced your `application.css` with an `application.scss` (like I always do):

```css
    @import "tellimus/pricing-table"
```

## Implementing Logging, Notifications, etc.

The included module defines the following empty "template methods" which you're able to provide an implementation for in `Subscription`:

 - `prepare_for_plan_change`
 - `prepare_for_new_subscription`
 - `prepare_for_upgrade`
 - `prepare_for_downgrade`
 - `prepare_for_cancelation`
 - `prepare_for_card_update`
 - `finalize_plan_change!`
 - `finalize_new_subscription!`
 - `finalize_upgrade!`
 - `finalize_downgrade!`
 - `finalize_cancelation!`
 - `finalize_card_update!`
 - `card_was_declined`

Be sure to include a call to `super` in each of your implementations, especially if you're using multiple concerns to break all this logic into smaller pieces.

Between `prepare_for_*` and `finalize_*`, so far I've used `finalize_*` almost exclusively. The difference is that `prepare_for_*` runs before we settle things with Stripe, and `finalize_*` runs after everything is settled in Stripe. For that reason, please be sure not to implement anything in `finalize_*` implementations that might cause issues with ActiveRecord saving the updated state of the subscription.

```
