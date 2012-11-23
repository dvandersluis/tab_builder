class OpenHash < ActiveSupport::HashWithIndifferentAccess
  class << self
    def [](hash = {})
      new(hash)
    end
  end
  
  def initialize(hash = {})
    super
    self.default = hash.default
  end
  
  def dup
    self.class.new(self)
  end

protected
  def convert_value(value)
    if value.is_a? Hash
      OpenHash[value].tap do |oh|
        oh.each do |k, v|
          oh[k] = convert_value(v) if v.is_a? Hash
        end
      end
    elsif value.is_a?(Array)
      value.dup.replace(value.map { |e| convert_value(e) })
    else
      value
    end
  end
  
  def method_missing(name, *args, &block)
    method = name.to_s
    
    case method
      when %r{.=$}
        super unless args.length == 1
        self[method[0...-1]] = args.first
      
      when %r{.\?$}
        super unless args.empty?
        self.key?(method[0...-1].to_sym)
        
      when %r{^_.}
        ret = self.send(method[1..-1], *args, &block)
        (ret.is_a?(Hash) and meth != :_default) ? OpenHash[ret] : ret 
        
      else
        if key?(method) or !respond_to?(method)
          self[method]
        else
          super
        end
    end
  end
end