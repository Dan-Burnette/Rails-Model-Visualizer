require File.expand_path '../../spec_helper.rb', __FILE__
require_relative "../../services/parse_association_line"

describe "ParseAssociationLine" do

  before(:all) do
    @from_model = "users"
  end

  describe "call" do

    it "sets from_model properly" do
      line_double = double("line").as_null_object
      association = ParseAssociationLine.call(@from_model, line_double)
      expect(association.from_model).to eq(@from_model)
    end

    context "no options" do

      it "parses type properly" do
        line = "some_association :project"
        association = ParseAssociationLine.call(@from_model, line)
        expect(association.type).to eq("some_association")
      end

      it "parses to_model properly" do
        line = "some_association :project"
        association = ParseAssociationLine.call(@from_model, line)
        expect(association.to_model).to eq("project")
      end

      it "parses through_model properly" do
        line = "some_association :project"
        association = ParseAssociationLine.call(@from_model, line)
        expect(association.through_model).to eq(nil)
      end

    end

    context "with class_name option" do

      it "parses to_model properly with hashrocket syntax" do
        line = "some_association :project, :class_name => 'Membership'"
        association = ParseAssociationLine.call(@from_model, line)
        expect(association.to_model).to eq("membership")
      end

      it "parses to_model properly with hash syntax" do
        line = "some_association :project, class_name: 'Membership'"
        association = ParseAssociationLine.call(@from_model, line)
        expect(association.to_model).to eq("membership")
      end

    end

    context "with through option" do

      it "parses through_model properly with hashrocket syntax" do
        line = "some_association :members, :through => :group_projects"
        association = ParseAssociationLine.call(@from_model, line)
        expect(association.through_model).to eq("group_projects")
      end

      it "parses through_model properly with hash syntax" do
        line = "some_association :members, through: :group_projects"
        association = ParseAssociationLine.call(@from_model, line)
        expect(association.through_model).to eq("group_projects")
      end

      context "with source option" do

        it "parses to_model properly with hashrocket syntax" do
          line = "some_association :members, :through => :group_projects :source => :person"
          association = ParseAssociationLine.call(@from_model, line)
          expect(association.to_model).to eq("person")
        end

        it "parses to_model properly with hash syntax" do
          line = "some_association :members, through: :group_projects, source: :person"
          association = ParseAssociationLine.call(@from_model, line)
          expect(association.to_model).to eq("person")
        end

      end

    end

  end

end
