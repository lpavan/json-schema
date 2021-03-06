module JSON
  class Schema
    class PropertiesAttribute < Attribute
      def self.validate(current_schema, data, fragments, processor, validator, options = {})
        if data.is_a?(Hash)
          current_schema.schema['properties'].each do |property,property_schema|
            if !data.has_key?(property) and property_schema['default'] and !property_schema['readonly'] and options[:insert_defaults]
              default = property_schema['default']
              data[property] = (default.is_a?(Hash) ? default.clone : default)
            end

            if property_schema['required'] and !data.has_key?(property)
              message = "The property '#{build_fragment(fragments)}' did not contain a required property of '#{property}'"
              validation_error(processor, message, fragments, current_schema, self, options[:record_errors])
            end
          
            if data.has_key?(property)
              schema = JSON::Schema.new(property_schema,current_schema.uri,validator)
              fragments << property
              schema.validate(data[property],fragments,processor,options)
              fragments.pop
            end
          end
        end
      end
    end
  end
end
