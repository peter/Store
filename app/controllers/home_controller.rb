class HomeController < ApplicationController
  before_filter :find_cart
  
  def index
    @products = Product.all
  end
  
  def add_to_cart
    product = Product.find(params[:id])
    create_cart unless @cart
    Rails.logger.debug("XXXX session=#{session[:cart_id]} cart content=#{@cart.content.inspect}")
    
    @cart.add_product!(product)
    respond_to do |format|
      format.js
    end
  end

  private
  
  def find_cart
    @cart = Cart.find(session[:cart_id]) if session[:cart_id]
  end
  
  def create_cart
    @cart = Cart.create
    session[:cart_id] = @cart.id
  end  
end
