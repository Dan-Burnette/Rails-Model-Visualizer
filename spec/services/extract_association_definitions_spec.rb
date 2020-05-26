require File.expand_path '../../spec_helper.rb', __FILE__
require_relative "../../services/extract_association_definitions"

describe "ExtractAssociationDefinitions" do

  before(:all) do
  end

  it "properly extracts single line association definitions" do
    content = "belongs_to :user\nhas_many :friends"
    result = ExtractAssociationDefinitions.call(content)
    expect(result).to eq(["belongs_to :user", "has_many :friends"])
  end

  it "properly extracts multiline association definititions (by combining them into one line)" do
    content = "belongs_to :user,\nclass_name: 'Person',\ndependent: :destroy"
    result = ExtractAssociationDefinitions.call(content)
    expect(result).to eq(["belongs_to :user, class_name: 'Person', dependent: :destroy"])
  end

end
