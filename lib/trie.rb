# Copyright (c) 2020 Dmitry Anufriev
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

# frozen_string_literal: true

require_relative 'node'
require_relative 'string'

# Implementation of compact prefix tree.
class Trie
  def initialize(nodes = {})
    @nodes = nodes
  end

  # Add word and value to prefix tree.
  #
  # @param [String] word
  # @param [Object] value
  # @return prefix tree with pair of the word and the value.
  def add(word, value)
    raise ArgumentError, "'word' can't be nil or empty" if word.nil? || word.blank?

    word = word.downcase
    key = word[0]
    nodes = {}.merge @nodes
    nodes[key] = nodes.key?(key) ? nodes[key].add(word, value) : Node.new(word, [value])
    Trie.new nodes
  end

  # Values that match the +prefix+. If trie does not contain the +prefix+ or the +prefix+ is nil or blank,
  # then an empty array returned.
  #
  # @param [String] prefix
  # @param [Symbol] match
  # @return [Enumerable] values for the +prefix+.
  def values(prefix, match = :starts_with)
    prefix.nil? || prefix.blank? || !@nodes.key?(prefix[0]) ? [] : @nodes[prefix[0]].values(prefix, match)
  end

  # Traverse all nodes.
  #
  # @param [Proc] block which will be invoked with node's depth, node's word and node's values.
  def traverse(&block)
    @nodes.values.each { |node| node.traverse(0, &block) }
  end
end
