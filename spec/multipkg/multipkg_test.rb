require 'spec_helper'

describe Puppet::Type.type(:multipkg) do

  before do
    Puppet::Util::Storage.stubs(:store)
  end

  it "should have an :packages property that is an array" do
    Puppet::Type.type(:multipkg).attrtype(:packages).should == :property
  end

end
