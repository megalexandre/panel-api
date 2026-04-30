# frozen_string_literal: true
module Receivables
  class ListService
    DEFAULT_PAGE = 1
    DEFAULT_PER_PAGE = 20
    MAX_PER_PAGE = 100
    DEFAULT_SORT_BY = "created_at"
    DEFAULT_SORT_DIRECTION = "desc"

    SORTABLE_COLUMNS = {
      "due_date" => :due_date,
      "amount" => :amount_cents,
      "created_at" => :created_at
    }.freeze
    SORT_DIRECTIONS = %w[asc desc].freeze

    def self.call(user_id:, with_discarded: false, page: DEFAULT_PAGE, per_page: DEFAULT_PER_PAGE, sort_by: DEFAULT_SORT_BY, sort_direction: DEFAULT_SORT_DIRECTION)
      relation = with_discarded ? Receivable.with_discarded : Receivable.active
      relation = relation.where(user_id: user_id)
      page_number = normalize_page(page)
      per_page_number = normalize_per_page(per_page)
      column = normalize_sort_by(sort_by)
      direction = normalize_sort_direction(sort_direction)

      total_count = relation.count
      total_pages = (total_count.to_f / per_page_number).ceil
      offset = (page_number - 1) * per_page_number

      {
        receivables: relation.order(column => direction).offset(offset).limit(per_page_number),
        pagination: {
          current_page: page_number,
          per_page: per_page_number,
          total_pages: total_pages,
          total_count: total_count
        }
      }
    end

    def self.normalize_page(page)
      number = page.to_i
      number.positive? ? number : DEFAULT_PAGE
    end

    def self.normalize_per_page(per_page)
      number = per_page.to_i
      normalized = number.positive? ? number : DEFAULT_PER_PAGE
      [normalized, MAX_PER_PAGE].min
    end

    def self.normalize_sort_by(sort_by)
      SORTABLE_COLUMNS.fetch(sort_by.to_s, SORTABLE_COLUMNS[DEFAULT_SORT_BY])
    end

    def self.normalize_sort_direction(sort_direction)
      SORT_DIRECTIONS.include?(sort_direction.to_s) ? sort_direction.to_sym : DEFAULT_SORT_DIRECTION.to_sym
    end
  end
end
