module Api
  module V1
    class ObservationSerializer
      include JSONAPI::Serializer
      
      belongs_to :subject
      belongs_to :setting, optional: true
      
      attributes :antecedent, :behavior, :consequence, :notes
      
      attribute :observed_at do |object|
        object.observed_at.iso8601
      end

      attribute :setting_name do |object|
        object.setting&.name
      end
    end
  end
end

