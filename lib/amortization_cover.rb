# frozen_string_literal: true

class AmortizationCover < DocumentHandler
  FILE_PATH = "folders/files/new_format/partials/_amortization_cover.html.erb"
  attr_reader :folder, :show_table, :quotation, :with_signature
  def initialize(folder, show_table, quotation, controller)
    @folder ||= folder
    @show_table ||= show_table
    @quotation ||= quotation
    @with_signature = false
    super(FILE_PATH, layout: "pdf", controller: controller)
  end

    protected

      def assigns
        {
            folder: folder,
            show_table: show_table,
            quotation: quotation,
            with_signature: with_signature
        }
      end
      def locals
        {}
      end
end
