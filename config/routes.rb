Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }

  devise_scope :user do
    get 'sign_in', to: 'devise/sessions#new', as: :new_user_session
    get 'sign_out', to: 'devise/sessions#destroy', as: :destroy_user_session
  end

  post 'locale/set', to: 'locale#update'

  %i(mounts minions).each do |resource|
    resources resource, only: [:index, :show]
  end

  resources :orchestrions, only: [] do
    get :select, on: :collection
  end

  %i(orchestrions emotes bardings hairstyles armoires).each do |resource|
    resources resource, only: [:index, :show] do
      post :add, :remove, on: :member
    end
  end

  get 'achievements/types', to: redirect('404')
  get 'achievements/types/:id', to: 'achievements#type', as: :achievement_type
  resources :achievements, only: [:index, :show]

  resources :characters, only: [:show, :destroy] do
    get :search, on: :collection
    post :select, on: :member
  end

  resources :titles, only: :index

  resources :leaderboards, only: :index do
    collection do
      get 'fc/:id', as: :free_company, action: :free_company
    end
  end

  get 'character/verify',     to: 'characters#verify',   as: :verify_character
  get 'character/settings',   to: 'characters#edit',     as: :character_settings
  post 'character/refresh',   to: 'characters#refresh',  as: :refresh_character
  post 'character/validate',  to: 'characters#validate', as: :validate_character
  patch 'character/update',   to: 'characters#update',   as: :update_character
  delete 'character/forget',  to: 'characters#forget',   as: :forget_character

  namespace :api do
    resources :characters, only: :show
    resources :users, only: :show

    %i(achievements titles mounts minions orchestrions emotes bardings hairstyles armoires).each do |resource|
      resources resource, only: [:index, :show]
    end
  end

  namespace :admin do
    resources :users, only: :index

    resources :characters, only: :index do
      delete :unverify, on: :member
    end

    resources :versions, only: [] do
      post :revert
    end
  end

  namespace :mod do
    %i(mounts minions orchestrions emotes bardings hairstyles armoires).each do |resource|
      resources resource, only: [:index, :edit, :update]
    end

    resources :sources, only: :destroy
    get 'dashboard', action: :index
  end

  get '404', to: 'home#not_found', as: :not_found
  match "api/*path", via: :all, to: -> (_) { [404, { 'Content-Type' => 'application/json' },
                                              ['{"status": 404, "error": "Not found"}'] ] }
  match "*path", via: :all, to: redirect('404')

  root 'home#index'
end
