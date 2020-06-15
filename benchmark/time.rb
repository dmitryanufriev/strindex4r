# frozen_string_literal: true

require 'benchmark'
require_relative 'names'
require_relative '../lib/trie'

trie = Trie.new
Names::ARRAY.each { |name| trie = trie.add name, 10 }

n = 50_000

puts 'PARTIAL MATCH'

Benchmark.bm do |benchmark|
  benchmark.report('Array (at start)') do
    n.times do
      Names::ARRAY.select { |name| name.start_with? 'jody' }
    end
  end

  benchmark.report("Trie\t\t\t") do
    n.times do
      trie.values 'jody'
    end
  end
end

Benchmark.bm do |benchmark|
  benchmark.report("Array (at end)\t") do
    n.times do
      Names::ARRAY.select { |name| name.start_with? 'george' }
    end
  end

  benchmark.report("Trie\t\t\t") do
    n.times do
      trie.values 'george'
    end
  end
end


