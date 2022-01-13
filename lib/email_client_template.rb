# frozen_string_literal: true

class EmailClientTemplate < ClientLiquidHandler
  def initialize(client, email_template)
    @template = email_template.template
    super(client)
  end

  def get_html
    locals[:code_block]
  end
end
