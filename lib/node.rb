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
    # Search by 'hello' will return both, 10 and 20.
    #
    # @raise ArgumentError when the word has no common prefix with the prefix in the node.
    # @param word [String] is the index pointed to the value.
    # @param value [Object] is the value.
    # @return Node with the word and the value.
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

    ###
    # Values matched to the index.
    #
    # When +match+ param is *:exact*, then exact value of the index will be searched. For example, if the index is 'abc'
    # then prefix in the node should be exactly 'abc'. If prefix in the node is different ('ab' or 'abcd' and so on),
    # then empty result will be returned.
    #
    # When +match+ param is *:start_with* then prefix in the node should start with the index value. For example, if the
    # index is 'ab' then values from the nodes with prefixes 'ab', 'abc' and so on will be returned.
    #
    # @param index [String] is a word for search.
    # @param match [Symbol] is a type of match. Can be either *:exact* or *:start_with*. Default is *:start_with*.
    # @return Enumerable of values or empty.
    ###
    def values(index, match: :start_with)
      common_prefix = CommonPrefix.new(@prefix, index).max
      return if common_prefix.empty?

      Enumerator.new do |yld|
        sffx_i = index.suffix(common_prefix)
        if sffx_i.empty? # node for the index was found
          case match
          when :exact
            @values.each { |value| yld << value } if @prefix == index
          when :start_with
            if @prefix.start_with? index
              @values.each { |value| yld << value }
              @descendants.values.each do |descendant|
                descendant.traverse { |_d, _w, values| values.each { |value| yld << value } }
              end
            end
          end
        else # try to get values from descendant nodes matched to the suffix of the index
          @descendants[sffx_i[0]]&.values(sffx_i, match: match)&.each { |value| yld << value }
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
