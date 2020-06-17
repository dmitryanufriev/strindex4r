# frozen_string_literal: true

require 'rspec'
require 'node'

describe 'Trie::Node' do
  before do
    @node = Trie::Node.new('hello', [10])
                      .add('hell', 20)
                      .add('help', 30)
  end

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
  end

  context 'values' do
    it 'should return value for exactly matched word' do
      expect(@node.values('hell', :exact).to_a).to eql [20]
    end

    it 'should return empty when no exactly matched word' do
      expect(@node.values('hel', :exact).to_a.empty?).to be true
    end

    it 'should return empty when word not exists' do
      expect(@node.values('helz', :exact).to_a.empty?).to be true
    end

    it 'should return values for all words' do
      expect(@node.values('hel', :starts_with).to_a.sort).to eql [10, 20, 30]
    end

    it 'should return values for first few letters of words' do
      expect(@node.values('hell', :starts_with).to_a.sort).to eql [10, 20]
    end

    it 'should return values for first letter of words' do
      expect(@node.values('h', :starts_with).to_a.sort).to eql [10, 20, 30]
    end

    it 'should return empty when no word matched to first few letters' do
      expect(@node.values('no', :starts_with).to_a.empty?).to be true
    end
  end
end
