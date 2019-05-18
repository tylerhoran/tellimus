Tellimus::Engine.routes.draw do
  resources :subscriptions, only: [:new]
  resources Tellimus.owner_resource, as: :owner do
    resources :subscriptions do
      member do
        post :cancel
      end
    end
  end
end
