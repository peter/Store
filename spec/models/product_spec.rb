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
        product = Product.create(:name => "My product")
        product.reload.name.should == "My product"        
      }.should change(Product, :count).by(1)
    end    
  end
end