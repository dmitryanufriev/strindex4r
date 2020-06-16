# frozen_string_literal: true

require 'benchmark'
require_relative 'names'
require_relative '../lib/trie'

trie = Names::ARRAY.reduce(Trie.new) { |tr, name| tr.add name, 10 }

n = 50_000

puts 'PARTIAL MATCH'

Benchmark.bm do |benchmark|
  benchmark.report('Array (at start)') do
    n.times do
      Names::ARRAY.select { |name| name.start_with? 'jody' }
    end
  end

  benchmark.report('Trie') do
    n.times do
      trie.values 'jody'
    end
  end
end

Benchmark.bm do |benchmark|
  benchmark.report('Array (at end)') do
    n.times do
      Names::ARRAY.select { |name| name.start_with? 'george' }
    end
  end

  benchmark.report('Trie') do
    n.times do
      trie.values 'george'
    end
  end
end
