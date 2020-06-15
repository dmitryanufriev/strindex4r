# frozen_string_literal: true

require 'faker'
require_relative './lib/trie'

names = []
trie = Trie.new
(1..100).each do |i|
  name = Faker::Name.first_name
  trie = trie.add name, 10
  names.append name
end

File.delete('names.txt') if File.exist? 'names.txt'
File.open('names.txt', 'w') do |file|
  names.each { |name| file.puts name.downcase }
end

size = 0
trie.traverse do |depth, word, values|
  size += 1
  p "#{'-' * depth}#{word}:#{values}"
end
p size
