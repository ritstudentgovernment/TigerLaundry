TigerLaundry::Application.routes.draw do

  devise_for :users, :controllers => {:omniauth_callbacks => "users/omniauth_callbacks"}

  resources :facilities do
    resources :submissions do
      collection do
        get 'limited'
      end
    end
  end

  resources :users


  # Map the root of the site to the pages controller
  root to: "pages#index"
  
end
