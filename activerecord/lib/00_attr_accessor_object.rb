
class AttrAccessorObject
  def self.my_attr_accessor(*names)
    names.each do |name|
      heredoc = <<-TEXT
        def #{name}
          @#{name}
        end
        
        def #{name}=(val)
          @#{name} = val
        end
      TEXT
      # define_method(name.to_sym) do
      #   "@#{name}"
      # end
      # define_method(name.to_sym) do
      # 
      # end
      self.class_eval(heredoc)
    end
  end
end
