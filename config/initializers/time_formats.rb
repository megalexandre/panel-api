# frozen_string_literal: true
[ Time, ActiveSupport::TimeWithZone, DateTime ].each do |klass|
  klass.class_eval do
    def as_json(*)
      strftime("%Y-%m-%d %H:%M:%S")
    end
  end
end
