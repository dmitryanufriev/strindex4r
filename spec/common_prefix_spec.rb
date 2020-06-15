# frozen_string_literal: true

require 'rspec'
require 'common_prefix'

describe 'CommonPrefix' do
  context 'max' do
    it 'should return longest common prefix' do
      expect(CommonPrefix.new('hello', 'help').max).to eql('hel')
    end

    it 'should return empty when no common prefix' do
      expect(CommonPrefix.new('abc', 'bcd').max.empty?).to be true
    end

    it 'should return empty when different cases' do
      expect(CommonPrefix.new('Hello', 'hello', false).max.empty?).to be true
    end
  end
end
