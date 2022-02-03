Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  namespace :api do
    namespace :v1 do
      post 'device/readings', to: 'device#create', defaults: { format: 'json' } 
      get 'device/count', to: 'device#cumulative_count', defaults: { format: 'json' } 
      get 'device/most_recent_reading', to: 'device#most_recent_reading', defaults: { format: 'json' } 
      get 'device/all_data', to: 'device#all_data', defaults: { format: 'json' } 
    end
  end
end
