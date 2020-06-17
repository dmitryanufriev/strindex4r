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

    # Add word with value to node.
    #
    # @param [String] word
    # @param [Object] value
    # @return node with new value
    # @raise ArgumentError when word is nil or empty.
    def add(word, value)
      raise ArgumentError, "Word can't be nil or empty" if word.nil? || word.blank?

      common_prefix = CommonPrefix.new(@prefix, word).max
      raise ArgumentError, "Node '#{@prefix}' has no common prefix with word '#{word}'" if common_prefix.blank?

      # Case A: @prefix:hello - word:hello
      if common_prefix.length == @prefix.length && common_prefix.length == word.length
        return Node.new @prefix, @values << value, @descendants
      end

      sffx_p = @prefix.suffix(common_prefix)
      sffx_w = word.suffix(common_prefix)
      # Case B: @prefix:hell - word:hello
      if sffx_p.empty?
        key = sffx_w[0]
        descendants = {}.merge @descendants
        descendants[key] = descendants.key?(key) ? descendants[key].add(sffx_w, value) : Node.new(sffx_w, Set[value])
        return Node.new common_prefix, @values, descendants
      end
      # Case C: @prefix:hello - word:hell
      if sffx_w.empty?
        descendants = { sffx_p[0] => Node.new(sffx_p, @values, {}.merge(@descendants)) }
        return Node.new common_prefix, Set[value], descendants
      end
      # Case D: @prefix:hell -> word:help
      descendants = {
        sffx_p[0] => Node.new(sffx_p, @values, {}.merge(@descendants)),
        sffx_w[0] => Node.new(sffx_w, Set[value])
      }
      Node.new common_prefix, Set[], descendants
    end

    # Return values matched to word.
    #
    # @param [String] word is a word for search.
    # @param [Symbol] match is a type of match. Can be either *:exact* or *:starts_with*. When match is :exact then values will be returned for word which exactly equal to +word+. When match is :starts_with then values will be returned for words which prefix is equal to +word+. Default value is :starts_with.
    # @return enumerable of values or empty if no words matched to 'word' parameter found.
    def values(word, match = :starts_with)
      Enumerator.new do |yld|
        if @prefix == word || match == :starts_with && @prefix.start_with?(word)
          @values.each { |value| yld << value }
          if match == :starts_with
            @descendants.values.each do |descendant|
              descendant.traverse { |_depth, _word, values| values.each { |value| yld << value } }
            end
          end
        else
          suffix = word.suffix(CommonPrefix.new(@prefix, word).max)
          key = suffix[0]
          @descendants[key].values(suffix, match).each { |value| yld << value } if @descendants.key?(key)
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
