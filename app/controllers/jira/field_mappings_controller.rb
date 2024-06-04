module Jira
# app/controllers/field_mappings_controller.rb
  class FieldMappingsController < ApplicationController
    def create
      project = Project.find(params[:field_mapping][:project_id])
      field_mapping_params = params.require(:field_mapping).permit(codegiant_field: [], jira_field: [])

      # Initialize a new hash for storing the mappings
      mapping_hash = {}

      # Iterate over the parameters and populate the mapping hash
      field_mapping_params[:codegiant_field].zip(field_mapping_params[:jira_field]).each do |codegiant_field, jira_field|
        if codegiant_field == 'Description'
          # If the field is 'Description', append the JIRA field to an array
          mapping_hash[codegiant_field] ||= []
          mapping_hash[codegiant_field] << jira_field
        else
          # For other fields, just assign the value
          mapping_hash[codegiant_field] = jira_field
        end
      end

      @field_mapping = project.field_mapping || FieldMapping.new(project: project)
      @field_mapping.mapping = mapping_hash
      @field_mapping.save
    end
  end
end
