module ServiceLogging
  module Masking
    # Masks sensitive information.
    #
    # @example
    #   mask("")         # => ""
    #   mask("1")        # => "*"
    #   mask("12")       # => "**"
    #   mask("123")      # => "***"
    #   mask("1234")     # => "***4"
    #   mask("12345")    # => "***45"
    #   mask("123456")   # => "***456"
    #   mask("1234567")  # => "****567"
    def self.mask(value)
      return nil unless value
      str = value.to_s.dup
      return "*" * str.size if str.size < 4

      show_length = str.size > 6 ? 3 : (str.size - 3)
      str[0...-show_length] = "*" * (str.size - show_length)
      str
    end
  end
end
