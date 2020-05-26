require File.expand_path '../../spec_helper.rb', __FILE__
require_relative "../../services/parse_association_definition"

describe "ParseAssociationDefinition" do

  before(:all) do
    @from_model = "users"
  end

  describe "call" do

    it "sets from_model properly" do
      line_double = double("line").as_null_object
      association = ParseAssociationDefinition.call([], @from_model, line_double)
      expect(association.from_model).to eq(@from_model)
    end

    context "no scope, no options" do

      it "parses type properly" do
        line = "some_association :project"
        association = ParseAssociationDefinition.call([], @from_model, line)
        expect(association.type).to eq("some_association")
      end

      it "parses to_model properly" do
        line = "some_association :project"
        association = ParseAssociationDefinition.call([], @from_model, line)
        expect(association.to_model).to eq("Project")
      end

      it "parses through_model properly" do
        line = "some_association :project"
        association = ParseAssociationDefinition.call([], @from_model, line)
        expect(association.through_model).to eq(nil)
      end

    end

    context "with class_name option" do

      it "parses to_model properly with hashrocket syntax" do
        line = "some_association :project, :class_name => 'Membership'"
        association = ParseAssociationDefinition.call([], @from_model, line)
        expect(association.to_model).to eq("Membership")
      end

      it "parses to_model properly with hash syntax" do
        line = "some_association :project, class_name: 'Membership'"
        association = ParseAssociationDefinition.call([], @from_model, line)
        expect(association.to_model).to eq("Membership")
      end

    end

    context "with through option" do

      it "parses through_model properly with hashrocket syntax" do
        line = "some_association :members, :through => :group_projects"
        association = ParseAssociationDefinition.call([], @from_model, line)
        expect(association.through_model).to eq("GroupProject")
      end

      it "parses through_model properly with hash syntax" do
        line = "some_association :members, through: :group_projects"
        association = ParseAssociationDefinition.call([], @from_model, line)
        expect(association.through_model).to eq("GroupProject")
      end

      context "with source option" do

        it "parses to_model properly with hashrocket syntax" do
          line = "some_association :members, :through => :group_projects :source => :person"
          association = ParseAssociationDefinition.call([], @from_model, line)
          expect(association.to_model).to eq("Person")
        end

        it "parses to_model properly with hash syntax" do
          line = "some_association :members, through: :group_projects, source: :person"
          association = ParseAssociationDefinition.call([], @from_model, line)
          expect(association.to_model).to eq("Person")
        end

      end

    end

    context "model and to_model are in the same namespace" do

      it "parses a properly namespaced to_model" do
        line = "some_association :members"
        association = ParseAssociationDefinition.call(["Project::User", "Project::Member"], "Project::User", line)
        expect(association.to_model).to eq("Project::Member")
      end

    end

  end

end
