Rails.application.routes.draw do
  get "tests/test"

  root :to => "tests#test"
end
