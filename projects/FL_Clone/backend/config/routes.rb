Rails.application.routes.draw do
  mount ActionCable.server => '/cable'
  
  namespace :api do
    namespace :v1 do
      post 'auth/register', to: 'auth#register'
      post 'auth/login', to: 'auth#login'
      post 'auth/refresh', to: 'auth#refresh'
      delete 'auth/logout', to: 'auth#logout'
      
      resources :users, only: [:index, :show, :update] do
        member do
          get :profile
          patch :update_profile
        end
      end
      
      resources :groups do
        member do
          post :join
          delete :leave
          get :members
        end
        resources :topics, only: [:index, :create, :show, :update, :destroy] do
          resources :comments, only: [:index, :create, :update, :destroy]
        end
      end
      
      resources :events do
        member do
          post :rsvp
          delete :cancel_rsvp
          get :attendees
        end
      end
      
      resources :posts do
        member do
          post :like
          delete :unlike
        end
        resources :comments, only: [:index, :create, :update, :destroy]
      end
      
      resources :conversations, only: [:index, :show, :create] do
        resources :messages, only: [:index, :create]
      end
      
      resources :notifications, only: [:index, :update, :destroy]
      
      resources :relationships, only: [:create, :destroy] do
        collection do
          get :followers
          get :following
        end
      end
      
      get 'search', to: 'search#index'
      
      resources :media, only: [:create, :show, :destroy]
      
      resources :reports, only: [:create]
      
      resources :kink_tags, only: [:index, :show, :create] do
        collection do
          get :popular
          get :categories
        end
      end
    end
  end
end

