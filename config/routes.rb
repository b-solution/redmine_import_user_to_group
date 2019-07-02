# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

resources :groups do
  member do
    match 'import_users', to: 'import_users#index', via: [:post, :get]
  end
end
