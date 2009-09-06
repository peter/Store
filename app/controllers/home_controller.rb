class HomeController < ApplicationController
  def index
    @products = Product.all
  end
  
  def add_to_cart
    product = Product.find(params[:id])
    find_cart
    Rails.logger.debug("XXXX session=#{session[:cart_id]} cart content=#{@cart.content.inspect}")
    
    @cart.add_product!(product)
    respond_to do |format|
      format.js
    end
  end

  private
  
  def find_cart
    if session[:cart_id]
      @cart = Cart.find(session[:cart_id])
    else
      @cart = Cart.create
      session[:cart_id] = @cart.id
    end
  end
end
