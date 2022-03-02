# frozen_string_literal: true

class BasePresenter
    attr_accessor :model
    
    def initialize(options = {})
      options.map { |k, v| send("#{k}=", v) if respond_to?("#{k}=") }
    end
  
    def respond_to_missing?(_method, *_args)
      model.present?
    end
  
    def method_missing(method, *args, &block)
      super unless model.respond_to?(method)
      model.send(method, *args, &block)
    end
end  