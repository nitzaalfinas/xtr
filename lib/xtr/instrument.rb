module Xtr
  # Abstract instrument.
  #
  # @abstract
  #
  # @example
  #   class Currency < Instrument
  #     quantity :decimal
  #     type :currency
  #   end
  class Instrument
    extend ActiveSupport::Autoload

    autoload :Currency
    autoload :Stock

    class << self
      # Get +Instrument+ class of specified +type+.
      #
      # @param type [String, Symbol] instrument type to get
      #
      # @return [Class] instrument class
      def for_type(type)
        const_get(type.to_s.capitalize)
      end

      # Get/set the type of quantity of the instrument.
      #
      # @param type [Symbol] quantity type (+:decimal+ or +:integer+)
      #
      # @return [Symbol]
      def quantity(type = nil)
        @quantity = type if type
        @quantity
      end

      # Get/set the instrument type (name).
      #
      # @param type [Symbol, String] instrument type
      #
      # @return [Symbol, String]
      def type(type = nil)
        @type = type if type
        @type
      end

      # Convert a number to quantity of instrument type.
      #
      # @param number [String, Numeric]
      #
      # @raise [XtrError]
      #
      # @return [Integer, BigDecimal]
      def convert_quantity(number)
        case quantity
        when :decimal
          Util.big_decimal(number)
        when :integer
          number.to_i
        else
          raise XtrError, "No quantity type for instrument '#{type}' defined"
        end
      end
    end

    delegate :convert_quantity, to: :class

    # Get instrument name.
    #
    # @abstract
    def name
      raise NotImplementedError
    end
  end

  # Cash instrument.
  class CashInstrument < Instrument
  end
end
