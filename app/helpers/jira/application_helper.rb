module Jira
  module ApplicationHelper
    def bootstrap_class_for(flash_type)
      case flash_type.to_sym
      when :notice
        'alert-info'
      when :alert, :error
        'alert-danger'
      else
        'alert-primary'
      end
    end
  end
end
