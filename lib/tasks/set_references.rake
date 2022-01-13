namespace :set_references do
  desc "Run set_references task"

  task run: :environment do
    Project.where(reference: nil).update_all(reference: "00")
    puts "Referencia de los proyectos actualizada"

    Phase.where(reference: nil).update_all(reference: "00")
    puts "Referencia de las fases actualizada"

    Stage.where(reference: nil).update_all(reference: "00")
    puts "Referencia de las etapas actualizada"
  end
end
