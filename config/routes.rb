TigerLaundry::Application.routes.draw do
  # Map the root of the site to the pages controller
  root to: "pages#index"

  # Facilities is shortened to /f/, and publically it can only do 'index' and 'show'
  resources :facilities, :path => 'f', :only => ['index', 'show'] do
    # Allow for new submissions, also shorten to /s/ to be friendly
    resources :submissions, :path => 's', :only => ['new']
  end
end
