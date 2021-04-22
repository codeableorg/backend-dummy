class VisitsController < ApplicationController
  def index
    Visit.create
    @visits = Visit.all
  end
end
