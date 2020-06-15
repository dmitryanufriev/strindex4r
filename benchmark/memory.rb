# frozen_string_literal: true

require 'get_process_mem'
require_relative 'names'
require_relative '../lib/trie'

GC.start
allocated_before = GC.stat(:total_allocated_objects)
freed_before = GC.stat(:total_freed_objects)
mem = GetProcessMem.new
puts "Memory usage before: #{mem.mb} MB."

# CODE

ftrie = Names::ARRAY.reduce(Trie.new) { |trie, name| trie.add name, 10 }

# END CODE

mem = GetProcessMem.new
puts "Memory usage after: #{mem.mb} MB."
GC.start
allocated_after = GC.stat(:total_allocated_objects)
freed_after = GC.stat(:total_freed_objects)
puts "Total objects allocated: #{allocated_after - allocated_before}"
puts "Total objects freed: #{freed_after - freed_before}"

p ftrie.values('george').to_a
