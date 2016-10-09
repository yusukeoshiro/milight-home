Rails.application.routes.draw do

  root :to => 'page#top'
  post "api/light/on",         :to => "light#on"
  post "api/light/off",        :to => "light#off"
  post "api/light/color",      :to => "light#color"
  post "api/light/brightness", :to => "light#brightness"

end