# Copyright (c) 2020 Dmitry Anufriev
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

# frozen_string_literal: true

require 'rspec'
require 'node'

describe 'Trie::Node' do
  context 'add' do
    it 'prefix:hello - word:hello should add value to existing node' do
      path = []
      Trie::Node.new('hello', [10].to_set).add('hello', 20).traverse do |depth, word, values|
        path << [depth, word, values.to_a]
      end
      expect(path).to eql [
        [0, 'hello', [10, 20]]
      ]
    end

    it 'prefix:hello - word:hello should store unique value only' do
      path = []
      Trie::Node.new('hello', [10].to_set).add('hello', 10).traverse do |depth, word, values|
        path << [depth, word, values.to_a]
      end
      expect(path).to eql [
        [0, 'hello', [10]]
      ]
    end

    it 'prefix:hell - word:hello should add new node' do
      path = []
      Trie::Node.new('hell', [10].to_set).add('hello', 20).traverse do |depth, word, values|
        path << [depth, word, values.to_a]
      end
      expect(path).to eql [
        [0, 'hell', [10]],
        [1, 'o', [20]]
      ]
    end

    it 'prefix:hell - word:hello should add value to existing subnode' do
      path = []
      Trie::Node.new('a', [10].to_set).add('ab', 20).add('ab', 30).traverse do |depth, word, values|
        path << [depth, word, values.to_a]
      end
      expect(path).to eql [
        [0, 'a', [10]],
        [1, 'b', [20, 30]]
      ]
    end

    it 'prefix:hello - word:hell should add new node' do
      path = []
      Trie::Node.new('hello', [10].to_set).add('hell', 20).traverse do |depth, word, values|
        path << [depth, word, values.to_a]
      end
      expect(path).to eql [
        [0, 'hell', [20]],
        [1, 'o', [10]]
      ]
    end

    it 'prefix:hello - word:help should add new nodes' do
      path = []
      Trie::Node.new('hello', [10].to_set).add('help', 20).traverse do |depth, word, values|
        path << [depth, word, values.to_a]
      end
      expect(path).to eql [
        [0, 'hel', []],
        [1, 'lo', [10]],
        [1, 'p', [20]]
      ]
    end

    it "should raise ArgumentError when word has no common prefix with node's prefix" do
      expect { Trie::Node.new('hello', [10].to_set).add('abc', 10) }.to raise_error(ArgumentError)
    end

    it 'should raise ArgumentError when word is nil' do
      expect { Trie::Node.new('hello', [10].to_set).add(nil, 10) }.to raise_error(ArgumentError)
    end

    it 'should raise ArgumentError when word is empty' do
      expect { Trie::Node.new('hello', [10].to_set).add('', 10) }.to raise_error(ArgumentError)
    end
  end

  context 'values' do
    let(:node) do
      Trie::Node.new('hello', [10].to_set)
                .add('help', 20)
                .add('hell', 30)
    end

    it 'should return value for exactly matched word' do
      expect(node.values('hello', match: :exact).to_a).to eql [10]
    end

    it 'should return empty when no exactly matched word' do
      expect(node.values('hel', match: :exact).to_a.empty?).to be true
    end

    it 'should return values for all matched words' do
      expect(node.values('hel', match: :starts_with).to_a.sort).to eql [10, 20, 30]
    end

    it 'should return values for first few letters of words' do
      expect(node.values('hell', match: :starts_with).to_a.sort).to eql [10, 30]
    end

    it 'should return empty when no word matched to first few letters' do
      expect(node.values('no', match: :starts_with).to_a.empty?).to be true
    end

    it 'should return values for first letter of words' do
      expect(node.values('h', match: :starts_with).to_a.sort).to eql [10, 20, 30]
    end
  end
end
