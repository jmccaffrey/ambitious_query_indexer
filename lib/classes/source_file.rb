require 'classes/object_call'
require 'modules/common_regex'

class SourceFile
  include CommonRegex
  
  attr_accessor :code, :file_name
  
  def initialize(code, opts = {})
    self.code = code
    self.file_name = opts[:file_name]
  end
  
  def object_calls
    finder_expression = /(#{common_regex(:variable)}+)\.(#{common_regex(:method)}+)(\(#{common_regex(:params)}+\))?/
    
    object_calls = []
    
    self.code.each do |line|
      next if line =~ /^\s*#/      # We don't analyse commented-out lines

      object_calls += line.scan(finder_expression).collect do |call|
        object, method, params = call[0], call[1], call[2]

        ObjectCall.new(self, :object => object, :method => method, :params => params)
      end
    end
    
    object_calls
  end
  
  def associations
    # Assumes that this file will have been required elsewhere in the application - ie, relies
    # on Rails' model loading stuff, and for tests, AQI requiring the files in the mock source tree

    begin
      klass = Object.const_get(self.class_name)
    rescue
      return nil
    end
    
    return unless klass < ActiveRecord::Base
    
    klass.reflections
  end
  
  def class_name
    file_name.gsub('.rb','').camelize
  end
end