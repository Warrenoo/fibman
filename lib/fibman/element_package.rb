# Element对象集合
# 将element的三种type拆分存储
# keys: key类型element hash
# actions: action类型element {controller_name: hash}
# urls: url类型element 以'/'分割的字典树
# 使用lazy_build方式生成keys actions urls，只在查询时构建
# mutex 为 true 时需要重新build
module Fibman
  class ElementPackage
    attr_reader :keys, :actions, :urls, :origin_elements, :mutex

    def initialize elements=[]

      @keys = {}
      @actions = {}
      @urls = Fibman::Trie.create
      @origin_elements = elements.group_by{ |e| e.type }

      rebuild
    end

    def set element
      raise ParameterIsNotValid, "param must be Element" unless element.is_a?(Fibman::Element)

      origin_elements[element.type] ||= []
      origin_elements[element.type] |= [element]

      rebuild
    end

    alias_method :<<, :set

    def mset *elements
      elements.flatten.each do |e|
        next unless e.is_a?(Fibman::Element)
        set e
      end
    end

    alias_method :append, :mset

    def + package
      self.class.new (origin_elements.values.flatten + package.origin_elements.values.flatten).uniq
    end

    def find_key k
      lazy_build
      keys[k.to_sym]
    end

    def find_action controller, action
      lazy_build
      actions&.dig(controller.to_s, action.to_s)
    end

    def find_url url
      lazy_build
      urls&.dig(*url.gsub(/^\/|\/$/, "").split(/\//))
    end

    def build
      build_keys
      build_actions
      build_urls
    end

    def lazy_build
      return if !mutex

      build
      finish_build
    end

    def finish_build
      @mutex = false
    end

    def rebuild
      @mutex = true
    end

    private

    def build_keys
      return unless origin_elements.has_key? 'key'

      origin_elements['key'].each { |e| keys[e.core] = e }
    end

    def build_actions
      return unless origin_elements.has_key? 'action'

      origin_elements['action'].each do |e|
        next unless e.core.is_a? Hash

        key = e.core[:controller].to_s
        actions[key] ||= {}
        actions[key][e.core[:action].to_s] = e
      end
    end

    def build_urls
      return unless origin_elements.has_key? 'url'

      origin_elements['url'].each do |e|
        next unless e.core.is_a? String

        # 过滤首尾 / 并以 / 分割
        split_url = e.core.gsub(/^\/|\/$/, "").split(/\//)
        split_url.each_with_index.reduce(urls) do |i, (j, index)|
          t = i.add_sub j, (index == split_url.size - 1 ? e : nil)
          t
        end
      end
    end

    class << self
      def merge *packages
        new (packages.reduce([]) { |a, e| a + e.origin_elements.values.flatten }).uniq
      end
    end
  end
end
