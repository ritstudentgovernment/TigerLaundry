TigerLaundry::Application.routes.draw do
  resources :submissions

  resources :facilities

  # Map the root of the site to the pages controller
  root to: "pages#index"
  
end
