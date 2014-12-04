unless defined?(KeyError)
  class KeyError < IndexError
  end
end

if (Object.instance_methods & ['singleton_class', :singleton_class]).empty?
  class Object
    def singleton_class
      class << self; self; end
    end
  end
end
