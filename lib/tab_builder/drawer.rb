module TabBuilder
  module Drawer
    def self.draw(tabset, context, &block)
      @context = context
      
      content_for :style do
        stylesheet_link_tag "tabbed"
      end
      
      out = ActiveSupport::SafeBuffer.new
      out << content_tag(:div, :class => 'tabstrip') do
        content_tag(:ul, :class => 'tabs') do
          tabset.inject(ActiveSupport::SafeBuffer.new) do |html, tab|
            current = false
            
            if !tab.current.nil?
              current = (tab.current.call === true)
            else
              tab.paths.each do |path|
                if p = Rails.application.routes.recognize_path(path.url, :method => path[:method])
                  current = (p[:controller] == params[:controller] and p[:action] == params[:action])
                  break if current
                end
              end
            
              current = (tab.controller == params[:controller]) unless current
            end
            
            if current
              html << content_tag(:li, :class => "tab current") do
                content_tag(:span, tab.name)
              end
            else
              html << content_tag(:li, :class => "tab") do
                link_to(tab.name, tab.root.url)
              end
            end
          
            html
          end
        end
      end
      
      out << content_tag(:div, :class => "tab_content") do
        content_tag(:div, :class => 'tab_content_inner') { @context.capture(&block) }
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
