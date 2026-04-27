module Receivables
  class ListService
    DEFAULT_PAGE = 1
    DEFAULT_PER_PAGE = 20
    MAX_PER_PAGE = 100

    def self.call(with_discarded: false, page: DEFAULT_PAGE, per_page: DEFAULT_PER_PAGE)
      relation = with_discarded ? Receivable.with_discarded : Receivable.active
      page_number = normalize_page(page)
      per_page_number = normalize_per_page(per_page)

      total_count = relation.count
      total_pages = (total_count.to_f / per_page_number).ceil
      offset = (page_number - 1) * per_page_number

      {
        receivables: relation.order(created_at: :desc).offset(offset).limit(per_page_number),
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
  end
end
