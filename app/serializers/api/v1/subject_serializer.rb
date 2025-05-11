module Api
  module V1
    class SubjectSerializer
      include JSONAPI::Serializer
      
      attributes :name, :date_of_birth, :notes

      attribute :created_at do |object|
        object.created_at.iso8601
      end

      attribute :age do |object|
        if object.date_of_birth.present?
          ((Time.current - object.date_of_birth.to_time) / 1.year).floor
        end
      end

      has_many :observations do |object|
        object.observations.order(observed_at: :desc).limit(5)
      end

      attribute :observations_count do |object|
        object.observations.count
      end
    end
  end
end

