module Fib
  class Trie
    attr_accessor :key, :data, :subnode

    def initialize key, data, subnode={}
      @key = key
      @data = data
      @subnode = subnode
    end

    def dig *node_key
      return nil unless node_key.is_a? Array

      if node_key.size < 1
        return data
      end

      current_key = node_key.first
      node_key.shift

      subnode.has_key?(current_key) ? subnode[current_key]&.dig(*node_key) : nil
    end

    def add_sub key, node
      t = Trie.new key, node
      subnode[key] = t
      t
    end
  end
end
