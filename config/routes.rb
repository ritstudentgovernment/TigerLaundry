TigerLaundry::Application.routes.draw do

  resources :facilities do
    resources :submissions
  end

  # Map the root of the site to the pages controller
  root to: "pages#index"
  
end
