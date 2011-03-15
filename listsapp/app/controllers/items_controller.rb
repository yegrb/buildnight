class ItemsController < ApplicationController

  before_filter :load_list

  def create
    @new_item = Item.new(params[:item].merge({ :list => @list }))
    if @new_item.save
      flash[:notice] = "New item added"
      redirect_to @list
    else
      render :file => 'lists/show'
    end
  end

  def update
    @item = Item.find(params[:id])
    if @item.update_attributes(params[:item])
      flash[:notice] = "Item updated"
      redirect_to @list
    else
      flash[:error] = @item.errors.full_messages.join('. ')
      redirect_to @list
    end
  end

  def destroy
    @item = Item.find(params[:id])
    @item.destroy
    flash[:notice] = "Removed item"
    redirect_to @list
  end

  private

  def load_list
    @list = List.find(params[:list_id])
  end
end
