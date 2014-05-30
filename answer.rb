#!/usr/bin/env ruby

# part1 solver
module Solver1
  class << self
    def make_tree(path)
      arr = path.partition('/')
      raise 'invalid format' unless arr[0].empty?
      tree = make_node('', arr[2])
      return tree.children[0]
    end

    # pretty print the DFS traversal
    def pp_dfs(tree)
      arr = []
      pp_dfs_helper(tree, arr)
      return arr.inspect
    end

    private
    def pp_dfs_helper(tree, arr)
      arr << tree.data
      tree.children.each do |child|
        new_arr = []
        arr << new_arr
        pp_dfs_helper(child, new_arr)
      end
    end

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

    # format the combination array to add the '-'
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
  end
end

class CTree
  attr_reader :data
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

  # this is the general DFS that can pass in a block
  def dfs(&block)
    yield @data
    @nodes.each do |node|
      node.dfs(&block)
    end
  end
end

# part2 solver
module Solver2
  class << self
    def tree2path(tree)
      dummytree = CTree.new('')
      dummytree.add_child(tree)
      path = ''
      tree2path_helper(dummytree, '', path)
      return path[1..-1]
    end

    private
    # this part we need to 'lift' the recursion one level up
    # so we can collect all the siblings. because of the natural
    # feature of the combination tree, we can always choose any
    # one child to perform DFS safely.
    def tree2path_helper(tree, current, path)
      path << '/' << current
      if !tree.children.empty?
        set = []
        # use reverse to be consistent with the sample in the problem
        tree.children.reverse_each do |child|
          set << child.data unless child.data.include?('-')
        end
        acc = set.inject('') {|acc, e| acc + e + '|'}[0..-2]
        tree2path_helper(tree.children[0], acc, path)
      end
    end
  end
end

# part3 solver
# Because of the nature of the combination tree, any two siblings are
# the synonyms. So we just need to go one level up, if the parent has
# an other child, that child is the synonym. Here we assume the path
# given is valid and can locate a node in the tree.
module Solver3
  class << self
    def synonym_detection(tree, path)
      dummytree = CTree.new('')
      dummytree.add_child(tree)
      names = path.split('/')
      last = names[-1]
      names = names[1..-2]
      current = tree
      names.each do |name|
        current.children.each do |child|
          if child.data == name
            current = child
            break
          end
        end
      end
      current.children.each do |child|
        if child.data != last
          names << child.data
          ret = names.inject('/') { |acc, e| acc + e + '/' }[0..-2]
          return ret
        end
      end
      return '' 
    end
  end
end

def usage
  puts 'usage:'
  puts 'answer.rb [-a1|-a2|-a3] [-p path]'
end

if ARGV[0] == '-a1' || ARGV[0] == '-a2' || ARGV[0] == '-a3'
  if ARGV[1] == '-p'
    path = ARGV[2]
  else
    usage
  end
  tree = Solver1.make_tree(path)
  if ARGV[0] == '-a1'
    puts Solver1.pp_dfs(tree)
  elsif ARGV[0] == '-a2'
    puts Solver2.tree2path(tree)
  else
    if ARGV[3] == '-i'
      if !ARGV[4].empty?
        puts Solver3.synonym_detection(tree, ARGV[4])
      else
        usage
      end
    else
      usage
    end
  end
else
  usage
end
