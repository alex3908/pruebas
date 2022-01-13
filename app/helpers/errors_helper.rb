# frozen_string_literal: true

module ErrorsHelper
  def render_500
    render "errors/500.html.erb", status: 500
  end

  def render_404
    render "errors/404.html.erb", status: 404, layout: request.path.starts_with?(disponibilidad_path) ? "availability" : "application"
  end
end
