namespace :update_clients_nationalities do
  desc "Run update_clients_nationalities task"

  task run: :environment do
    PhysicalClient.all.each do |client|
      update_nationalities(client)
    end

    MoralClient.all.each do |client|
      update_nationalities(client)
    end
  end

  def update_nationalities(client)
    case client.nationality
    when "Afgano"
      client.update_attributes(nationality: "Afgana")
    when "Albano"
      client.update_attributes(nationality: "Albana")
    when "Alemán"
      client.update_attributes(nationality: "Alemana")
    when "Angolano"
      client.update_attributes(nationality: "Angolana")
    when "Argelino"
      client.update_attributes(nationality: "Argelina")
    when "Argentino"
      client.update_attributes(nationality: "Argentina")
    when "Armenio"
      client.update_attributes(nationality: "Armenia")
    when "Australiano"
      client.update_attributes(nationality: "Australiana")
    when "Austríaco"
      client.update_attributes(nationality: "Austríaca")
    when "Beliceño"
      client.update_attributes(nationality: "Beliceña")
    when "Beninés"
      client.update_attributes(nationality: "Beninesa")
    when "Bieloruso"
      client.update_attributes(nationality: "Bielorusa")
    when "Boliviano"
      client.update_attributes(nationality: "Boliviana")
    when "Botsuano"
      client.update_attributes(nationality: "Botsuana")
    when "Brasileño"
      client.update_attributes(nationality: "Brasileña")
    when "Británico"
      client.update_attributes(nationality: "Británica")
    when "Búlgaro"
      client.update_attributes(nationality: "Búlgara")
    when "Caboverdiano"
      client.update_attributes(nationality: "Caboverdiana")
    when "Camboyano"
      client.update_attributes(nationality: "Camboyana")
    when "Camerunés"
      client.update_attributes(nationality: "Camerunesa")
    when "Ceilanés"
      client.update_attributes(nationality: "Ceilanesa")
    when "Centroafricano"
      client.update_attributes(nationality: "Centroafricana")
    when "Checo"
      client.update_attributes(nationality: "Checa")
    when "Chileno"
      client.update_attributes(nationality: "Chilena")
    when "Colombiano"
      client.update_attributes(nationality: "Colombiana")
    when "Cubano"
      client.update_attributes(nationality: "Cubana")
    when "Danés"
      client.update_attributes(nationality: "Danesa")
    when "Dominicano"
      client.update_attributes(nationality: "Dominicana")
    when "Ecuatoriano"
      client.update_attributes(nationality: "Ecuatoriana")
    when "Egipcio"
      client.update_attributes(nationality: "Egipcia")
    when "Esloveno"
      client.update_attributes(nationality: "Eslovena")
    when "Español"
      client.update_attributes(nationality: "Española")
    when "Estonio"
      client.update_attributes(nationality: "Estonia")
    when "Filipino"
      client.update_attributes(nationality: "Filipina")
    when "Finés"
      client.update_attributes(nationality: "Finésa")
    when "Francés"
      client.update_attributes(nationality: "Francesa")
    when "Griego"
      client.update_attributes(nationality: "Griega")
    when "Groenlandés"
      client.update_attributes(nationality: "Groenlandésa")
    when "Guatemalteco"
      client.update_attributes(nationality: "Guatemalteca")
    when "Haitiano"
      client.update_attributes(nationality: "Haitiana")
    when "Hondureño"
      client.update_attributes(nationality: "Hondureña")
    when "Húngaro"
      client.update_attributes(nationality: "Húngara")
    when "Indio"
      client.update_attributes(nationality: "India")
    when "Irlandés"
      client.update_attributes(nationality: "Irlandesa")
    when "Islandés"
      client.update_attributes(nationality: "Islandesa")
    when "Italiano"
      client.update_attributes(nationality: "Italiana")
    when "Jamaiquino"
      client.update_attributes(nationality: "Jamaiquina")
    when "Japonés"
      client.update_attributes(nationality: "Japonesa")
    when "Kiribatiano"
      client.update_attributes(nationality: "Kiribatiana")
    when "Letonio"
      client.update_attributes(nationality: "Letonia")
    when "Libanés"
      client.update_attributes(nationality: "Libanesa")
    when "Lituano"
      client.update_attributes(nationality: "Lituana")
    when "Macedonio"
      client.update_attributes(nationality: "Macedonia")
    when "Malayo"
      client.update_attributes(nationality: "Malaya")
    when "Maltés"
      client.update_attributes(nationality: "Maltesa")
    when "Mexicano"
      client.update_attributes(nationality: "Mexicana")
    when "Moldavo"
      client.update_attributes(nationality: "Moldava")
    when "Monaqués"
      client.update_attributes(nationality: "Monaquesa")
    when "Neerlandés"
      client.update_attributes(nationality: "Neerlandesa")
    when "Nigeriano"
      client.update_attributes(nationality: "Nigeriana")
    when "Norcoreano"
      client.update_attributes(nationality: "Norcoreana")
    when "Noruego"
      client.update_attributes(nationality: "Noruega")
    when "Panameño"
      client.update_attributes(nationality: "Panameña")
    when "Paraguayo"
      client.update_attributes(nationality: "Paraguaya")
    when "Peruano"
      client.update_attributes(nationality: "Peruana")
    when "Polaco"
      client.update_attributes(nationality: "Polaca")
    when "Portugués"
      client.update_attributes(nationality: "Portuguesa")
    when "Ruso"
      client.update_attributes(nationality: "Rusa")
    when "Salvadoreño"
      client.update_attributes(nationality: "Salvadoreña")
    when "Serbio"
      client.update_attributes(nationality: "Serbia")
    when "Sueco"
      client.update_attributes(nationality: "Sueca")
    when "Suizo"
      client.update_attributes(nationality: "Suiza")
    when "Surinamés"
      client.update_attributes(nationality: "Surinamesa")
    when "Tailandés"
      client.update_attributes(nationality: "Tailandesa")
    when "Turco"
      client.update_attributes(nationality: "Turca")
    when "Uruguayo"
      client.update_attributes(nationality: "Uruguaya")
    when "Uzbeko"
      client.update_attributes(nationality: "Uzbeka")
    when "Venezolano"
      client.update_attributes(nationality: "Venezolana")
    else
      puts "La nacionalidad #{client.nationality} del cliente #{client.id} ya se ha actualizado anteriormente o no está considerada en los casos."
    end
  end
end