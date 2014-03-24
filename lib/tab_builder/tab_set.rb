module TabBuilder
  class TabSet
    include Enumerable
    
    attr_accessor :options
    
    def initialize(options, context, &block)
      @options = options.to_openhash || OpenHash.new
      @context = context
      @tabs = []
      
      # Copy over context instance variables
      @context.instance_variables.each do |iv|
        instance_variable_set(iv, @context.instance_variable_get(iv)) unless instance_variable_defined? iv
      end
      
      instance_eval &block if block_given?        
    end
    
    def each
      @tabs.each { |i| yield i }
    end
    
    def add(tab)
      @tabs << tab
    end
    alias_method :<<, :add
    
    def draw(&block)
      Drawer.draw(self, @context, &block)
    end
    
    def method_missing(name, *args, &block)
      options = args.extract_options!
      tab = Tab.new(name, @options.merge(options), @context, &block)
      self << tab
    end
  end
end