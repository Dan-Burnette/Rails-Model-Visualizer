require_relative "../models/association"

class ExtractAssociationLines < ApplicationService

  def initialize(content)
    @content = content
    puts "extracting lines from content:"
    puts content.inspect
  end

  def call
    lines.select { |l| defines_association?(l) }
  end

  private

  def lines
    @content.split("\n")
  end

  def defines_association?(line)
    return false if line.empty?
    first_word = line.split(' ')[0]
    association_types.any? { |root| first_word.include? root }
  end

  def association_types
    ["belongs_to", "has_one", "has_many", "has_and_belongs_to_many"]
  end

end
