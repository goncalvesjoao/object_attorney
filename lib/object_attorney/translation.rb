module ObjectAttorney

  module Translation

    def human_attribute_name(attribute_key_name, options = {})
      no_translation = "-- no translation --"
      
      defaults = ["object_attorney.attributes.#{represented_object_class.to_s.underscore}.#{attribute_key_name}".to_sym]
      defaults << options[:default] if options[:default]
      defaults.flatten!
      defaults << no_translation
      options[:count] ||= 1
      
      translation = I18n.translate(defaults.shift, options.merge(default: defaults))

      if translation == no_translation && represented_object_class.respond_to?(:human_attribute_name)
        translation = represented_object_class.human_attribute_name(attribute_key_name, options)
      end

      translation
    end

  end

end