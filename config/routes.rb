Rails.application.routes.draw do
  
  get '/show', to: 'scrapers#show_model_graph'

  root to: 'scrapers#index'
end
