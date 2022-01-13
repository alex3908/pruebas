namespace :separate_lots_name_and_number do
  desc "Run separate lots name and number task"

  task run: :environment do
    lots = Lot.all

    lots.each do |lot|
      name = lot.read_attribute('name')
      number = name.scan(/\d+/).first
      label = name.tr("0-9", "")
      label = label.tr(" ", "")

      lot.update(number: number, label: label)
    end
  end

  def letter?(lookAhead)
    lookAhead =~ /[[:alpha:]]/
  end

  def number?(lookAhead)
    lookAhead =~ /[[:digit:]]/
  end
end