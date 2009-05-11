=begin
Module to be included into model class.

Copyright (C) 2009 Andrey “A.I.” Sitnik <andrey@sitnik.ru>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
=end

module PlainRecord
  # Module to be included into model class.
  #
  #   class Post
  #     include PlainRecord::Resource
  #     
  #     property :title
  #   end
  module Resource
    class << self
      def included(base)
        base.send :extend, self
      end
    end
    
    @@properties = []
    
    # Create new model instance with some +data+.
    def initialize(data)
      @data = data
    end
    
    # Return array of all property names.
    def properties
      @@properties
    end
    
    private
    
    # Add property to model with some +name+.
    #
    # You can provide your own define logic by +definers+. Definer Proc
    # will be call with property name in firts argument and may return
    # +:accessor+, +:writer+ or +:reader+ this method create standart methods
    # to access to property.
    def property(name, *definers)
      @@properties << name
      accessors = {:reader => true, :writer => true}
      
      definers.each do |definer|
        access = definer.call(name)
        if :writer == access or access.nil?
          accessors[:reader] = false
        end
        if :reader == access or access.nil?
          accessors[:writer] = false
        end
      end
      
      if accessors[:reader]
        class_eval <<-EOS, __FILE__, __LINE__
          def #{name}
            @data[:#{name}]
          end
        EOS
      end
      if accessors[:writer]
        class_eval <<-EOS, __FILE__, __LINE__
          def #{name}=(value)
            @data[:#{name}] = value
          end
        EOS
      end
    end
  end
end
