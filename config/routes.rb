Spree::Core::Engine.routes.draw do
  namespace :admin do
    resources :orders do
      resources :invoices, only: [:index, :new, :create]
    end
    resources :shipments do
      resource :documents, only: [:show]
    end
    resources :invoices, except: [:index, :new, :create]
  end
end
