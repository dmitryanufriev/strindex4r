# frozen_string_literal: true

require 'rspec'
require 'node'

describe 'Trie::Node' do
  before do
    @node = Trie::Node.new('hello', [10])
                      .add('hell', 20)
                      .add('help', 30)
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

    it 'should return values except duplicates' do
      node = @node.add('hela', 10).add('hela', 10)
      expect(node.values('hela', :starts_with).to_a).to eql [10]
    end
  end
end
