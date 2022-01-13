# frozen_string_literal: true

class DocumentsSignatures < DocumentHandler
  FILE_PATH = "folders/files/documents_signatures.html.erb"
  attr_reader :folder
  def initialize(folder, controller)
    @folder ||= folder
    super(FILE_PATH, layout: "pdf", controller: controller)
  end

    protected

      def assigns
        {
            folder: folder
        }
      end

      def locals
        {}
      end
end
