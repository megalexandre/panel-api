# frozen_string_literal: true

class Bordero
  class ListService
    DEFAULT_PAGE = 1
    DEFAULT_PER_PAGE = 20
    MAX_PER_PAGE = 100
    DEFAULT_SORT_BY = "change_date"
    DEFAULT_SORT_DIRECTION = "desc"

    SORTABLE_COLUMNS = {
      "change_date"        => :change_date,
      "created_at"         => :created_at,
      "total_amount_cents" => :total_amount_cents,
      "average_days"       => :average_days
    }.freeze
    SORT_DIRECTIONS = %w[asc desc].freeze

    def self.call(user_id:, page: DEFAULT_PAGE, per_page: DEFAULT_PER_PAGE, sort_by: DEFAULT_SORT_BY, sort_direction: DEFAULT_SORT_DIRECTION)
      relation    = ::Bordero.where(user_id: user_id)
      page_num    = normalize_page(page)
      per_page_num = normalize_per_page(per_page)
      column      = normalize_sort_by(sort_by)
      direction   = normalize_sort_direction(sort_direction)

      total_count = relation.count
      total_pages = (total_count.to_f / per_page_num).ceil
      offset      = (page_num - 1) * per_page_num

      {
        borderos: relation.order(column => direction).offset(offset).limit(per_page_num),
        pagination: {
          current_page: page_num,
          per_page:     per_page_num,
          total_pages:  total_pages,
          total_count:  total_count
        }
      }
    end

    def self.normalize_page(page)
      n = page.to_i
      n.positive? ? n : DEFAULT_PAGE
    end

    def self.normalize_per_page(per_page)
      n = per_page.to_i
      n = n.positive? ? n : DEFAULT_PER_PAGE
      [n, MAX_PER_PAGE].min
    end

    def self.normalize_sort_by(sort_by)
      SORTABLE_COLUMNS.fetch(sort_by.to_s, SORTABLE_COLUMNS[DEFAULT_SORT_BY])
    end

    def self.normalize_sort_direction(sort_direction)
      SORT_DIRECTIONS.include?(sort_direction.to_s) ? sort_direction.to_sym : DEFAULT_SORT_DIRECTION.to_sym
    end
  end
end
