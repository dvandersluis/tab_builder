module TabBuilder
  module Drawer
    def self.draw(tabset, context, &block)
      @context = context
      
      content_for :style do
        stylesheet_link_tag 'tab_builder'
      end
      
      out = ActiveSupport::SafeBuffer.new
      out << render(partial: 'tab_builder/tab_strip', locals: { tabs: tabset })
            
      out << content_tag(:div, class: 'tab-content') do
        content_tag(:div, class: 'tab_content_inner') { @context.capture(&block) }
      end if block_given?

      out
    end
    
    def self.method_missing(name, *args, &block)
      # Pass methods along to the context, if it responds to them (allows for helpers, etc. to be used):
      if @context.respond_to? name
        @context.send(name, *args, &block)
      else
        super(name, *args, &block)
      end
    end
  end
end
