Rails.application.routes.draw do
  
  get '/index', to: 'scrapers#index'

  get '/show', to: 'scrapers#show'
end
