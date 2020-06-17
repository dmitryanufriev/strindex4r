# Copyright (c) 2020 Dmitry Anufriev
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

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
      expect(CommonPrefix.new('Hello', 'help', false).max.empty?).to be true
    end

    it 'should return empty string when first word is empty' do
      expect(CommonPrefix.new('', 'help').max.empty?).to be true
    end

    it 'should return empty string when second word is empty' do
      expect(CommonPrefix.new('hello', '').max.empty?).to be true
    end

    it 'should return empty string when first word is nil' do
      expect(CommonPrefix.new(nil, 'help').max.empty?).to be true
    end

    it 'should return empty string when second word is nil' do
      expect(CommonPrefix.new('hello', nil).max.empty?).to be true
    end
  end
end
