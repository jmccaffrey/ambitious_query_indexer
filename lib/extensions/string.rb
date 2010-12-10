require 'modules/common_regex'

class String
  include CommonRegex
  
  def parametize
    self.gsub(/[()]/,"").split(',').collect(&:strip)
  end
  
  def is_rails_view?
    ((self =~ /\.html\.(erb|haml)/ or self =~ /\.rhtml/) ? true : false)
  end
  
  def is_rails_controller?
    (self =~ /_controller\.rb$/i ? true : false)
  end
  
  def is_rails_helper?
    (self =~ /_helper\.rb$/i ? true : false)
  end
  
  def as_rails_model
    File.split(self).last.gsub('.rb','').camelize
  end
  
  def is_rails_model?
    name = self.as_rails_model
    begin
      Object.const_defined?(name.to_sym) ?  Object.const_get(name) < ActiveRecord::Base  :  false
    rescue
      false
    end
  end
end
