Rails.application.routes.draw do
  resource :publishers, only: [:show] do
    member do
      post :update_publisher_data
    end
  end
end
