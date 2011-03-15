class ListsController < ApplicationController

  before_filter :load_object, :only => [:show, :edit, :update, :destroy]

  def index
    @lists = List.all
  end

  def show
  end

  def new
    @list = List.new
  end

  def create
    @list = List.new(params[:list])
    @list.save
    flash[:notice] = "Created your new list!"
    redirect_to lists_url
  end

  def edit
  end

  def update
    @list.update_attributes(params[:list])
    flash[:notice] = "Your list was updated!"
    redirect_to @list
  end

  def destroy
    @list.destroy
    flash[:notice] = "List removed"
    redirect_to lists_url
  end

  private

  def load_object
    @list = List.find(params[:id])
  end

end
