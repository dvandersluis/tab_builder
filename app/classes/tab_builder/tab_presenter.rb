module TabBuilder
  class TabPresenter
    attr_reader :tab
    delegate :name, :options, to: :tab

    def initialize(template, tab)
      @tab = tab
      @template = template
    end

    def classes
      (current? ? %w(tab current) : %w(tab)).join(" ")
    end

    def title
      tab.tooltip ? tooltip : label
    end

  private

    def label
      current? ? content_tag(:span, name) : link_to(name, url)
    end

    def tooltip
      t = tab.options[:tooltip]
      options = t.slice(:title, :icon)
      options[:label] = content_tag(:span, name)

      unless current?
        options[:link] = { onclick: nil }
        options[:url] = url
      end

      accessible_tooltip(t.fetch(:type, :help), options) { t[:text] }
    end

    def url
      tab.root.url if tab.root
    end

    def method_missing(*args, &block)
      return @template.send(*args, &block) if @template.respond_to?(args.first)
      super
    end

    def respond_to_missing?(*args)
      return true if @template.respond_to?(*args)
      super
    end

    def current?
      if !tab.current.nil?
        current = (tab.current.call === true)
      else
        tab.paths.each do |path|
          if p = Rails.application.routes.recognize_path(path.url, method: path[:method])
            current = (p[:controller] == params[:controller] and p[:action] == params[:action])
            break if current
          end
        end

        current = (tab.controller == params[:controller]) unless current
      end

      current
    end
  end
end
