class ProductsController < ApplicationController
  before_filter :require_admin_user

  # GET /products
  # GET /products.xml
  def index
    @products = Product.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @products }
    end
  end

  # GET /products/1
  # GET /products/1.xml
  def show
    @product = Product.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @product }
    end
  end

  # GET /products/new
  # GET /products/new.xml
  def new
    @product = Product.new
    @image = @product.images.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @product }
    end
  end

  # GET /products/1/edit
  def edit
    @product = Product.find(params[:id])
  end

  # POST /products
  # POST /products.xml
  def create
    @product = Product.new(params[:product])

    respond_to do |format|
      if @product.save
        flash[:notice] = 'Product was successfully created.'
        format.html { redirect_to(@product) }
        format.xml  { render :xml => @product, :status => :created, :location => @product }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @product.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /products/1
  # PUT /products/1.xml
  def update
    @product = Product.find(params[:id])

    respond_to do |format|
      if @product.update_attributes(params[:product])
        flash[:notice] = 'Product was successfully updated.'
        format.html { redirect_to(@product) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @product.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1
  # DELETE /products/1.xml
  def destroy
    @product = Product.find(params[:id])
    @product.destroy

    respond_to do |format|
      format.html { redirect_to(products_url) }
      format.xml  { head :ok }
    end
  end
  
  def create_comment
    @product = Product.find(params[:id])
    @comment = @product.comments.build(params[:comment])
    if @comment.save
      render :update do |page|
        page['no_comments'].hide
        page.insert_html :bottom, 'comment_list', :partial => 'comment', :object => @comment
        page.replace_html 'comment_confirm', 'Comment submitted'
        page['comment_confirm'].highlight(:slow)
        page['comment_form'].reset
      end
    else
      render :update do |page|
        page.replace_html 'comment_confirm', ''
        page.alert "Could not add comment for the following reasons:\n" + 
          @comment.errors.full_messages.map {|m| "* #{m}"}.join("\n") + 
          "\nPlease change your input and submit the form again."
      end
    end
  end
  
  def create_image
    @product = Product.find(params[:id])
    @image = @product.images.build(params[:image])
    if @image.save
      flash[:notice] = "Image added"
      redirect_to @product
    else
      flash[:notice] = "Image could not be added: #{@image.errors.full_messages}"
      redirect_to @product      
    end
  end
end
