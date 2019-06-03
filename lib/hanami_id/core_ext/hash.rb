module HanamiId
  module CoreExt
    module Hash
      # Returns a new hash with all keys converted to symbols, as long as
      # they respond to +to_sym+. This includes the keys from the root hash
      # and from all nested hashes and arrays.
      #
      #   hash = { 'person' => { 'name' => 'Rob', 'age' => '28' } }
      #
      #   hash.deep_symbolize_keys
      #   # => {:person=>{:name=>"Rob", :age=>"28"}}
      def deep_symbolize_keys
        deep_transform_keys { |key| key.to_sym rescue key }
      end

      # Returns a new hash with all keys converted by the block operation.
      # This includes the keys from the root hash and from all
      # nested hashes and arrays.
      #
      #  hash = { person: { name: 'Rob', age: '28' } }
      #
      #  hash.deep_transform_keys{ |key| key.to_s.upcase }
      #  # => {"PERSON"=>{"NAME"=>"Rob", "AGE"=>"28"}}
      def deep_transform_keys(&block)
        _deep_transform_keys_in_object(self, &block)
      end

      private

      # support methods for deep transforming nested hashes and arrays
      def _deep_transform_keys_in_object(object, &block)
        case object
        when Hash
          object.each_with_object({}) do |(key, value), result|
            result[yield(key)] = _deep_transform_keys_in_object(value, &block)
          end
        when Array
          object.map { |e| _deep_transform_keys_in_object(e, &block) }
        else
          object
        end
      end
    end
  end
end

Hash.prepend HanamiId::CoreExt::Hash
