# frozen_string_literal: true

module TagsHelper
  def fa_tooltip(name, title)
    "<i class='fa fa-#{name}' aria-hidden='true' data-toggle='tooltip' data-placement='top' title='#{title}'></i>".html_safe
  end
end
