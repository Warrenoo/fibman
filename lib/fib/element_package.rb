# Element对象集合
# 将element的三种type拆分存储
# keys: key类型element hash
# actions: action类型element {controller_name: hash}
# urls: url类型element 以'/'分割的字段树
require 'set'
module Fib
  class ElementPackage
    attr_accessor :keys, :actions, :urls, :origin_elements

    def initialize(elements)
      return nil unless elements.is_a? Array

      @origin_elements = elements.group_by(&:type)
      convert
    end

    def convert
      build_keys
      build_actions
      build_urls
    end

    private

    def build_keys
      return unless origin_elements.has_key? 'key'

      @keys = origin_elements['key'].reduce({}) { |a, e| a[e.core] = e; a }
    end

    def build_actions
      return unless origin_elements.has_key? 'action'

      @actions = origin_elements['action'].reduce({}) do |a, e|
        next unless e.core.is_a? Hash

        key = e.core[:controller].to_s
        a[key] ||= {}
        a[key][e.core[:action]] = e
        a
      end
    end

    def build_urls
      return unless origin_elements.has_key? 'url'

      root_trie = Trie.new(".", Element.new)
      @urls = origin_elements['url'].reduce(root_trie) do |a, e|
        next unless e.core.is_a? String

        split_url = e.core.split(/\//)
        split_url.each_with_index.reduce(root_trie) do |i, (j, index)|
          t = i.add_node j, (index == split_url.size - 1 ? e : nil)
          t
        end
      end
    end
  end
end
