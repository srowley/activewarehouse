require "spec_helper"

describe ActiveWarehouse::SlowlyChangingDimension, :new => true do

  before(:all) do
    @old_product = FactoryGirl.create(:base_product, :expiration_date => Time.gm(2006, 11, 30), :latest_version => 0)
    @new_product = FactoryGirl.create(:base_product, :effective_date => Time.gm(2006, 12, 1), :expiration_date => Time.gm(9999, 1, 1))
    @another_product = FactoryGirl.create(:base_product)
  end
  
  after(:all) do
    DatabaseCleaner.clean
  end

  describe "#latest_version_attribute" do
    it "returns :latest_version by default" do
      ProductDimension.latest_version_attribute.should == :latest_version
    end
  end
  
  describe "#effective_date_attribute" do
    it "returns :effective_date by default" do
      ProductDimension.effective_date_attribute.should == :effective_date
    end
  end
  
  describe "#expiration_date_attribute" do
    it "returns :expiration_date by default" do
      ProductDimension.expiration_date_attribute.should == :expiration_date
    end
  end
  
  describe "#find" do
    it "returns a result scoped to all effective versions" do
      ProductDimension.find(:all).length.should == 2
    end
    it "returns nil if only older versions meet the query criteria" do
      ProductDimension.find_by_id(@old_product.id).should be_nil
    end 
  end
  
  describe "#count" do
    it "returns a result scoped to effective versions only" do
      ProductDimension.count.should == 2
    end
  end
  
  describe "#find_with_older" do
    it "returns results including expired versions" do
      found_product = ProductDimension.find_with_older(@old_product.id).first
      found_product.effective_date.should == @old_product.effective_date
    end
    it "but results still include effective versions" do
      found_product = ProductDimension.find_with_older(@new_product.id).first
      found_product.effective_date.should == @new_product.effective_date
    end
  end
  
  describe "#valid_on" do
    it "returns only the results effective at the given time" do
      found_products = ProductDimension.unscoped.valid_on(Date.parse('2006-02-01'))
      found_products.count.should == 2
    end
    it "does not return the results from invalid items" do
      found_products = ProductDimension.unscoped.valid_on(Date.parse('2006-02-01'))
                                                .where('effective_date = ?', @new_product.effective_date)
                                                .first
      found_products.should be_nil
    end
  end

end
