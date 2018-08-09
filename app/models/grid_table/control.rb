class GridTable::Control
  include ActiveModel::Model

  attr_writer :model, :attribute, :source, :source_class, :source_column, :filter

  def filter(param_filter_value, records)
    unless @filter == false
      arel_query = {
        exact_match: ->(col) { col.eq(param_filter_value) },
        prefix:      ->(col) { col.matches("#{param_filter_value}%") },
        suffix:      ->(col) { col.matches("%#{param_filter_value}") },
        fuzzy:       ->(col) { col.matches("%#{param_filter_value}%") }
      }[strategy].call(source_table[column])

      prepared_records(records).where(arel_query)
    end
  end

  def sort(param_sort_order, records)
    sort_order = %w[asc, desc].include?(param_sort_order) ? param_sort_order : 'asc'

    prepared_records(records).order("#{table_with_column} #{sort_order}")
  end

  def url_param
    @source || @attribute
  end

  private

  def prepared_records(records)
    joined_control? ? records.joins(active_source) : records
  end

  def column
    @source_column || @attribute
  end

  def active_source
    @source || @model
  end

  def joined_control?
    @model != active_source
  end

  def strategy
    @filter || :fuzzy
  end

  def source_table
    klass = Object.const_get(@source_class || active_source.to_s.classify)
    klass.arel_table
  end

  def table_with_column
    "#{source_table.name}.#{column}"
  end

  class << self
    def find_by_param(param, controls)
      controls.detect { |control| control.url_param == param.try(:to_sym) }
    end
  end
end
