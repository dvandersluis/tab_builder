module TabBuilder
  module Builder
    def self.build(context = nil, options = {}, &block)
      TabSet.new(options, context, &block)
    end
  end
end