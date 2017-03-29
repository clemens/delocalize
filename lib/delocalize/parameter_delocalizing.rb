module Delocalize
  module ParameterDelocalizing
    def delocalize(options)
      delocalize_hash(self, options)
    end

  private

    def delocalize_hash(hash, options, base_key_stack = [])
      hash.each do |key, value|
        key_stack = [*base_key_stack, key] # don't modify original key stack!

        hash[key] = case
                    when value.respond_to?(:each_pair)
                      delocalize_hash(value, options, key_stack)
                    when Array === value
                      key_stack += [:[]] # pseudo-key to denote arrays
                      value.map { |item| delocalize_parse(options, key_stack, item) }
                    else
                      delocalize_parse(options, key_stack, value)
                    end
      end
    end

    def delocalize_parse(options, key_stack, value)
      parser = delocalize_parser_for(options, key_stack)
      return value unless parser
      begin
        parser.parse(value)
      rescue ArgumentError
        value
      end
    end

    def delocalize_parser_for(options, key_stack)
      parser_type = key_stack.reduce(options) do |h, key|
        case h
        when Hash
          h = h.stringify_keys
          key = key.to_s
          if key =~ /\A-?\d+\z/ && !h.key?(key)
            h
          else
            h[key]
          end
        when Array
          break unless key == :[]
          h.first
        else
          break
        end
      end

      return unless parser_type

      parser_name = "delocalize_#{parser_type}_parser"
      respond_to?(parser_name, true) ?
        send(parser_name) :
        raise(Delocalize::ParserNotFound.new("Unknown parser: #{parser_type}"))
    end

    def delocalize_number_parser
      @delocalize_number_parser ||= Parsers::Number.new
    end

    def delocalize_time_parser
      @delocalize_time_parser ||= Parsers::DateTime.new(Time)
    end

    def delocalize_date_parser
      @delocalize_date_parser ||= Parsers::DateTime.new(Date)
    end

  end
end
