namespace :create_identification_types do
  desc "Moves every Identification to de crud"
  task run: :environment do
    ine = IdentificationType.create_with(display_as: 'Credencial para votar', institution: "Instituto Nacional Electoral").find_or_create_by(name:'INE')
    ife = IdentificationType.create_with(display_as: 'Credencial para votar', institution: "Instituto Federal Electoral").find_or_create_by(name:'IFE')
    cedula = IdentificationType.create_with(display_as: 'Cédula Profesional', institution: "Secretaría de Educación Pública").find_or_create_by(name:'Cédula Profesional')
    passport = IdentificationType.create_with(display_as: 'Pasaporte', institution: "Secretaría de Relaciones Exteriores").find_or_create_by(name:'Pasaporte')

    MoralClient.find_each do |client|
      id = client.read_attribute('identification_type')
      company_id = client.read_attribute('company_identification_type')

      if id == 'INE'
        client.identification_type = ine
      elsif id == 'IFE'
        client.identification_type = ife
      elsif id == 'CÉDULA PROFESIONAL'
        client.identification_type = cedula
      elsif id == 'PASAPORTE'
        client.identification_type = passport
      end

      if company_id == 'INE'
        client.company_identification_type = ine
      elsif company_id == 'IFE'
        client.company_identification_type = ife
      elsif company_id == 'CÉDULA PROFESIONAL'
        client.company_identification_type = cedula
      elsif company_id == 'PASAPORTE'
        client.company_identification_type = passport
      end

      client.save
    end

    PhysicalClient.find_each do |client|
      id = client.read_attribute('identification_type')
      if id == 'INE'
        client.identification_type = ine
      elsif id == 'IFE'
        client.identification_type = ife
      elsif id == 'CÉDULA PROFESIONAL'
        client.identification_type = cedula
      elsif id == 'PASAPORTE'
        client.identification_type = passport
      end

      client.save
    end

  end
end
