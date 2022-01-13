# frozen_string_literal: true

class PurchaseConditions < DocumentHandler
  FILE_PATH = "folders/files/purchase_conditions.html.erb"
  NEW_FILE_PATH = "folders/files/new_format/purchase_conditions.html.erb"
  attr_reader :folder, :with_copy, :with_signature

  def initialize(folder, with_copy = true, with_signature = true)
    @folder ||= folder
    @with_copy = with_copy
    @with_signature = with_signature

    format = true ? NEW_FILE_PATH : FILE_PATH
    super(format, layout: "pdf")
  end

    protected

      def assigns
        {
            project: folder.project,
            folder: folder,
            with_copy: with_copy,
            with_signature: with_signature
        }
      end

      def locals
        {}
      end
end
