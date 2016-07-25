require 'active_model'
require 'object_attorney/version'
require 'object_attorney/helpers'
require 'object_attorney/class_methods'

module ObjectAttorney

  def self.included(base_class)
    base_class.extend ClassMethods
    base_class.extend ActiveModel::Validations::HelperMethods
  end

  def defendant_is_innocent?
    proven_innocent = defendants.map do |defendant|
      innocent_of_all_accusations?(defendant)
    end.all?

    make_the_parent_guilty unless proven_innocent

    proven_innocent
  end

  alias valid? defendant_is_innocent?

  def invalid?
    !valid?
  end

  protected ######################### PROTECTED ################################

  def defendants
    defendant =
      if parent_defendant
        Helpers.extend_errors_if_necessary(parent_defendant)

        Helpers.call_method!(parent_defendant, defendant_options[:name])
      else
        Helpers.call_method!(self, defendant_options[:name])
      end

    [defendant].flatten.compact
  end

  def innocent_of_all_accusations?(defendant)
    Helpers.extend_errors_if_necessary(defendant)

    return true if Helpers.marked_for_destruction?(defendant)

    founded_accusations(defendant).all?(&:sustained?)

    defendant.errors.empty?
  end

  def make_the_parent_guilty
    return unless parent_defendant

    parent_defendant.errors.add(defendant_options[:name], :invalid)
  end

  private ############################ PRIVATE #################################

  def parent_defendant
    return nil unless defendant_options[:in]

    @parent_defendant ||= send(defendant_options[:in])
  end

  def defendant_options
    self.class.defendant_options
  end

  def founded_accusations(defendant)
    self.class.allegations.values.flatten.uniq.map do |allegation|
      allegation.founded_accusation(self, defendant)
    end.compact
  end

end

require 'object_attorney/base'
