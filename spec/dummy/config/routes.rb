Rails.application.routes.draw do
  mount Tellimus::Engine, at: "tellimus"
  scope module: 'tellimus' do
    get 'pricing' => 'subscriptions#index', as: 'pricing'
  end
end
