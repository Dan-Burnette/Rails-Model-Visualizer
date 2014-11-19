Rails.application.routes.draw do
  
  get '/show', to: 'scrapers#show_model_graph'

  get '/showlaravel', to: 'scrapers#show_model_graph_laravel'

  root to: 'scrapers#index'
end
