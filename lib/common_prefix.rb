# Copyright (c) 2020 Dmitry Anufriev
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

# frozen_string_literal: true

# Represents common prefix between two words.
class CommonPrefix
  def initialize(word_a, word_b, ignore_case = true)
    @word_a = word_a
    @word_b = word_b
    @ignore_case = ignore_case
  end

  # Returns a longest common prefix between two words passed into a constructor. For example, the longest common prefix
  # between 'hello' and 'help' will be 'hel'.
  #
  # @return string, which is the longest common prefix between two words or empty string if no common prefix.
  def max
    max_prefix_size = [@word_a.length, @word_b.length].min - 1
    max_prefix_size.downto(0) do |prefix_size|
      prefix_a = @word_a[0..prefix_size]
      prefix_b = @word_b[0..prefix_size]
      return prefix_a if @ignore_case && prefix_a.casecmp(prefix_b).zero?
      return prefix_a if prefix_a == prefix_b
    end
    ''
  end
end
