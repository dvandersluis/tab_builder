module TabBuilder
  class Tab
    attr_accessor :paths, :controller
    
    delegate :options, :to => :@tabset
    
    def initialize(tabset, name, context, &block)
      @tabset = tabset
      @name = name
      @context = context
      @current = nil
      
      @paths = []
      @controller = nil
      
      # Copy over context instance variables
      @context.instance_variables.each do |iv|
        instance_variable_set(iv, @context.instance_variable_get(iv)) unless instance_variable_defined? iv
      end
      
      instance_eval &block if block_given?
    end
    
    def name
      I18n.t("#{options.string_prefix}#{@name}")  
    end
    
    # Define the path(s) for this tab (ie. what paths correspond to this tab)
    def path(url, options = {})
      url = url_for(url.merge(:only_path => false)) if url.is_a? Hash
      @paths << OpenHash.new({ :url => url, :method => options.delete(:method) || :get }) 
    end
    
    # Get the root path (ie. what path the tab links to
    def root
      @paths.first
    end
    
    # Getter/setter for controller
    def controller(name = nil)
      @controller = name if name
      @controller
    end
    
    # Override how to specify a current tab
    def current(&block)
      @current = block if block_given?
      @current
    end

    def method_missing(name, *args, &block)
      # Pass methods along to the context, if it responds to them (allows for helpers, etc. to be used):
      if @context.respond_to? name
        @context.send(name, *args, &block)
      else
        super(name, *args, &block)
      end
    end
  end
end