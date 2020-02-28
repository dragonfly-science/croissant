module FilterHelper
  def active_filter_names(filter)
    return [] unless active_filters?(filter)

    filter.active_filters.keys.map do |active_filter|
      t("filter.#{filter.class}.#{active_filter}")
    end
  end

  def active_filters?(filter)
    return false if filter.blank?

    return false unless filter.active_filters.any?

    true
  end
end
