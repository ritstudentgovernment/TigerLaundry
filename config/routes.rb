TigerLaundry::Application.routes.draw do

  resources :facilities do
    resources :submissions do
      collection do
        get 'limited'
      end
    end
  end


  # Map the root of the site to the pages controller
  root to: "pages#index"
  
end
