class VisitsController < ApplicationController
  def index
    Visit.create
    @visits = Visit.all
    @secret = ENV['MY_SECRET_VAR']
  end
end
