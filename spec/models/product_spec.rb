require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Product do
  describe "validation" do
    it "without a name" do
      product = Product.new
      product.should_not be_valid
      product.errors.on(:name).should be_present
    end
  end
  
  describe "creating" do
    it "with a name" do
      lambda {
        create_product
        @product.reload.name.should == "My product"        
      }.should change(Product, :count).by(1)
    end    
  end
  
  describe "images" do
    before(:each) do
      create_product
    end
    
    it "can be added" do
      lambda {
        image = @product.images.create
        @product.reload.images.count.should == 1
        @product.images.should include(image)
      }.should change(Image, :count).by(1)
    end
  end
  
  ###########################################
  #
  # Helper methods
  #
  ###########################################
  
  def create_product
    @product = Product.create(:name => "My product")    
  end
end
