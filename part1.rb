#!/usr/bin/env ruby

module Utility
  class << self
    def combination(arr, n)
      ret = []
      0.upto(arr.size - n) do |i|
        temp = []
        i.upto(i+n-1) do |j|  
          temp << arr[j]
        end
        ret << temp
      end
      return ret
    end

    def gen_comb(arr)
      ret = []
      1.upto(arr.size) do |i|
        combination(arr, i).each do |e|
          ret << e
        end
      end
      return ret
    end

    def format_comb(arr)
      ret = []
      arr.each do |sub_arr|
        if sub_arr.size > 1
          # use dash to connect the multiple strings         
          ret << sub_arr.inject('') {|acc, e| acc + e + '-' }[0..-2]
        elsif sub_arr.size == 1
          ret << sub_arr[0]
        else
          # do nothing...
        end
      end
      return ret
    end

    def parse_a_slash(str)
      arr = str.partition('/')
      return [arr[0], arr[2]]
    end

    def parse_comb(str)
      return str.split('|')
    end

    def make_node(data, path)
      tree = CTree.new(data)
      nxt, rem = parse_a_slash(path)
      nxt = parse_comb(nxt)
      nxt = gen_comb(nxt.reverse)
      nxt = format_comb(nxt)
      nxt.each do |data|
        tree.add_child(make_node(data, rem))
      end
      return tree
    end

    def make_tree(path)
      arr = path.partition('/')
      raise 'invalid format' unless arr[0].empty?
      tree = make_node('', arr[2])
      return tree.children[0]
    end
  end
end

class CTree
  def initialize(data)
    @data = data
    @nodes = []
  end

  def add_child(node)
    @nodes << node
  end

  def children
    @nodes
  end

  def dfs(&block)
    yield @data
    @nodes.each do |node|
      node.dfs(&block)
    end
  end
end


path = ARGV[1]
path = '/home/sports|music/misc|favorites'
tree = Utility.make_tree(path)
tree.dfs do |node|
  puts node
end
