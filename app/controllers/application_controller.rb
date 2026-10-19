class ApplicationController < ActionController::API
  private

  def render_errors(errors)
    render json: { errors: errors }, status: :unprocessable_content
  end
end
