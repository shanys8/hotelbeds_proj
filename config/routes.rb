Rails.application.routes.draw do
  get '/search_hotels' => 'hotelbeds#search_hotels'
  get '/book_hotel' => 'hotelbeds#book_hotel'
end
