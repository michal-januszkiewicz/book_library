module Pagination
  extend ActiveSupport::Concern

  DEFAULT_PAGE = 1
  DEFAULT_PER_PAGE = 20
  MAX_PER_PAGE = 100

  private

  def paginate(scope)
    scope.limit(per_page).offset((page - 1) * per_page)
  end

  def page
    [ params[:page].to_i, DEFAULT_PAGE ].max
  end

  def per_page
    requested = params[:per_page].to_i
    requested = DEFAULT_PER_PAGE unless requested.positive?

    [ requested, MAX_PER_PAGE ].min
  end
end
