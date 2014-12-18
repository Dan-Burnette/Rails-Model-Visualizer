Rails.application.routes.draw do
  
  get '/show_model_graph', to: 'scrapers#show_model_graph'

  get '/show_repo_controllers', to: 'scrapers#show_repo_controllers'

  get '/show_all', to: 'scrapers#show_all'
  
  root to: 'scrapers#index'
end
