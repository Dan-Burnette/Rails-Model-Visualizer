Rails.application.routes.draw do
  
  get '/show_model_graph', to: 'scrapers#show_model_graph'

  get '/show_repo_controllers', to: 'scrapers#show_repo_controllers'
  
  root to: 'scrapers#index'
end
