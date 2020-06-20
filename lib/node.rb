# Copyright (c) 2020 Dmitry Anufriev
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

# frozen_string_literal: true

require_relative 'string'
require_relative 'common_prefix'

class Trie
  # Node which contains prefix and subnodes with suffixes.
  class Node
    def initialize(prefix, values, descendants = {})
      @prefix = prefix
      @values = values
      @descendants = descendants
    end

    ###
    # Add word with value.
    #
    # If node already contains the word, then value will be added to existing one. For example, there is node with word
    # 'hello' and value 10, after adding 'hello' with value 20 there will be node with word 'hello' and values 10, 20.
    # Search by 'hello' will return both.
    #
    # @param [String] word is the index pointed to the value.
    # @param [Object] value is the value.
    # @return Node with the word and the value.
    # @raise ArgumentError when the word has no common prefix with the prefix in the node.
    ###
    def add(word, value)
      common_prefix = CommonPrefix.new(@prefix, word).max
      raise ArgumentError, "Node '#{@prefix}' has no common prefix with word '#{word}'" if common_prefix.blank?

      sffx_p = @prefix.suffix(common_prefix)
      sffx_w = word.suffix(common_prefix)
      if sffx_p.empty? && sffx_w.empty? # Case A: @prefix:hello - word:hello
        Node.new @prefix, @values << value, @descendants
      elsif sffx_p.empty? # Case B: @prefix:hell - word:hello
        Node.new @prefix, @values, @descendants.merge(
          { sffx_w[0] => @descendants[sffx_w[0]]&.add(sffx_w, value) || Node.new(sffx_w, Set[value]) }
        )
      elsif sffx_w.empty? # Case C: @prefix:hello - word:hell
        Node.new word, Set[value], {
          sffx_p[0] => Node.new(sffx_p, @values, {}.merge(@descendants))
        }
      else # Case D: @prefix:hell -> word:help
        Node.new common_prefix, Set[], {
          sffx_p[0] => Node.new(sffx_p, @values, {}.merge(@descendants)),
          sffx_w[0] => Node.new(sffx_w, Set[value])
        }
      end
    end

    # Return values matched to word.
    #
    # @param [String] index is a word for search.
    # @param [Symbol] match is a type of match. Can be either *:exact* or *:starts_with*.
    # @return enumerable of values or empty if no words matched to 'word' parameter found.
    def values(index, match: :starts_with)
      common_prefix = CommonPrefix.new(@prefix, index).max
      return if common_prefix.empty?

      Enumerator.new do |yld|
        sffx = index.suffix(common_prefix)
        if sffx.empty?
          case match
          when :exact
            @values.each { |value| yld << value } if @prefix == index
          when :starts_with
            if @prefix.start_with? index
              @values.each { |value| yld << value }
              @descendants.values.each do |descendant|
                descendant.traverse { |_d, _w, values| values.each { |value| yld << value } }
              end
            end
          end
        else
          @descendants[sffx[0]]&.values(sffx, match: match)&.each { |value| yld << value }
        end
      end
    end

    # Traverse node and all descendant nodes.
    #
    # @param [Integer] depth is a depth of the node in Trie. Default value is 0.
    # @param [Proc] block is a block which will be invoked with node's depth, node's word and node's values.
    def traverse(depth = 0, &block)
      block.call(depth, @prefix, @values)
      @descendants.values.each { |node| node.traverse(depth + 1, &block) }
    end
  end
end
