# frozen_string_literal: true

class EmailFolderTemplate < PurchasePromise
  FILE_PATH = "email_templates/template.html.erb"

  def initialize(folder, email_template)
    @template = email_template.template
    super(folder)
  end

  def get_html
    locals[:code_block]
  end
end
