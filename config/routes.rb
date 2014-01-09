Spree::Core::Engine.routes.draw do
  namespace :admin do
    resources :orders do
      resources :invoices, only: [:index, :new, :create]
      resources :documents, only: [:index, :new, :create]
    end
    resources :shipments do
      resource :shipment_documents, only: [:show]
    end
    resources :invoices, except: [:index, :new, :create]
    resources :documents, except: [:index, :new, :create]
  end
end
