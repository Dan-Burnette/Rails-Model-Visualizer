require_relative "../models/association"

class ExtractAssociationLines < ApplicationService

  def initialize(content)
    @content = content
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
    Association::TYPES.any? { |type | first_word.include? type }
  end

end