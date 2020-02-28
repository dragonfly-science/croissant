class Filter
  # This is an abstract class and shouldn't be used directly.
  # To create a new type of filter, create a new service that inherits from Filter
  # For each attribute you want to filter on,
  # add an attr_reader
  # add a filter_by_x method that takes items, query
  # gives x the value of the query or a transformed value of the query (this helps with forms)
  # and returns the filtered items
  # ie:
  # NewFilter < Filter
  #   attr_reader :something
  #   def filter_by_something(items, query)
  #     @something = query
  #     items.where(something: query)
  #   end
  # end

  FILTER_METHOD_PREFIX = "filter_by_".freeze
  attr_reader :active_filters, :unfiltered_size, :filtered_size
  def initialize(items, filter_params)
    @items = items
    @unfiltered_size = items.size
    @filter_params = filter_params.presence || default_params
    @active_filters = {}
  end

  def filter
    @filter_params.each do |key, value|
      next unless filter_methods.include?(method_name_for_key(key))

      next if value.nil? || value == "" || value == [""]

      @items = send(method_name_for_key(key), @items, value)
      @active_filters[key.to_sym] = instance_variable_get("@#{key}")
    end
    remove_default_params_from_active_filters

    @filtered_size = @items.size
    @items
  end

  def filter_methods
    @filter_methods ||= methods.select do |method|
      method.to_s.start_with?(FILTER_METHOD_PREFIX)
    end
  end

  def default_params
    {}
  end

  private

  def remove_default_params_from_active_filters
    @active_filters.delete_if { |k, v| default_params[k] == v }
  end

  def method_name_for_key(key)
    "#{FILTER_METHOD_PREFIX}#{key}".to_sym
  end
end
