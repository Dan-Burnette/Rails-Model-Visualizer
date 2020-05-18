require File.expand_path '../../spec_helper.rb', __FILE__
require_relative "../../services/parse_association_line"

describe "ParseAssociationLine" do

  before(:all) do
    @from_model = "users"
  end

  it "sets from_model properly" do
    line_double = double("line").as_null_object
    association = ParseAssociationLine.call(@from_model, line_double)
    expect(association.from_model).to eq @from_model
  end

  context "belongs_to association" do

    before(:all) do
      @line = "belongs_to :project"
    end

    it "parses type properly" do
      association = ParseAssociationLine.call(@from_model, @line)
      expect(association.type).to eq("belongs_to")
    end

    it "parses to_model properly" do
      association = ParseAssociationLine.call(@from_model, @line)
      expect(association.to_model).to eq("project")
    end

    it "parses through_model properly" do
      association = ParseAssociationLine.call(@from_model, @line)
      expect(association.through_model).to eq(nil)
    end

  end

  context "has_one association" do

    context "no options" do 

      before(:all) do
        @line = "has_one :project"
      end

      it "parses type properly" do
        association = ParseAssociationLine.call(@from_model, @line)
        expect(association.type).to eq("has_one")
      end

      it "parses to_model properly" do
        association = ParseAssociationLine.call(@from_model, @line)
        expect(association.to_model).to eq("project")
      end

      it "parses through_model properly" do
        association = ParseAssociationLine.call(@from_model, @line)
        expect(association.through_model).to eq(nil)
      end

    end

    context "with through option" do

      it "parses through_model properly with hashrocket syntax" do
        line = "has_one :project, :through => :membership"
        association = ParseAssociationLine.call(@from_model, line)
        expect(association.through_model).to eq("membership")
      end

      it "parses through_model properly with hash syntax" do
        line = "has_one :project, through: :membership"
        association = ParseAssociationLine.call(@from_model, line)
        expect(association.through_model).to eq("membership")
      end

      context "with additional options" do

        it "parses through_model properly with hashrocket syntax" do
          line = "has_one :project, :option_one => :thing_one, :through => :membership, :option_two => :thing_two"
          association = ParseAssociationLine.call(@from_model, line)
          expect(association.through_model).to eq("membership")
        end

        it "parses through_model properly with hash syntax" do
          line = "has_one :project, option_one: :thing_one, through: :membership, option_two: :thing_two"
          association = ParseAssociationLine.call(@from_model, line)
          expect(association.through_model).to eq("membership")
        end

      end

    end

  end

  context "has_many association" do

    context "no options" do 

      before(:all) do
        @line = "has_many :projects"
      end

      it "parses type properly" do
        association = ParseAssociationLine.call(@from_model, @line)
        expect(association.type).to eq("has_many")
      end

      it "parses to_model properly" do
        association = ParseAssociationLine.call(@from_model, @line)
        expect(association.to_model).to eq("project")
      end

      it "parses through_model properly" do
        association = ParseAssociationLine.call(@from_model, @line)
        expect(association.through_model).to eq(nil)
      end

    end

    context "with through option" do

      it "parses through_model properly with hashrocket syntax" do
        line = "has_many :projects, :through => :membership"
        association = ParseAssociationLine.call(@from_model, line)
        expect(association.through_model).to eq("membership")
      end

      it "parses through_model properly with hash syntax" do
        line = "has_many :projects, through: :membership"
        association = ParseAssociationLine.call(@from_model, line)
        expect(association.through_model).to eq("membership")
      end

      context "with additional options" do

        it "parses through_model properly with hashrocket syntax" do
          line = "has_many :projects, :option_one => :thing_one, :through => :membership, :option_two => :thing_two"
          association = ParseAssociationLine.call(@from_model, line)
          expect(association.through_model).to eq("membership")
        end

        it "parses through_model properly with hash syntax" do
          line = "has_many :projects, option_one: :thing_one, through: :membership, option_two: :thing_two"
          association = ParseAssociationLine.call(@from_model, line)
          expect(association.through_model).to eq("membership")
        end

      end

    end

  end

  context "has_and_belongs_to_many association" do

    before(:all) do
      @line = "has_and_belongs_to_many :projects"
    end

    it "parses type properly" do
      association = ParseAssociationLine.call(@from_model, @line)
      expect(association.type).to eq("has_and_belongs_to_many")
    end

    it "parses to_model properly" do
      association = ParseAssociationLine.call(@from_model, @line)
      expect(association.to_model).to eq("project")
    end

    it "parses through_model properly" do
      association = ParseAssociationLine.call(@from_model, @line)
      expect(association.through_model).to eq(nil)
    end

  end

end
