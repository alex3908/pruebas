namespace :add_total_sale_to_folders do
    desc "Set total sale value to folders"
  
    task run: :environment do
        Folder.where(total_sale: nil).each do |folder|
            quotation = folder.generate_quote
            folder.update(total_sale: quotation.total_with_discount)
        end
    end
end
