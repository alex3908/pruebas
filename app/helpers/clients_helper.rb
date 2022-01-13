# frozen_string_literal: true

module ClientsHelper
  def nationalities
    ["Afgana", "Albana", "Alemana", "Angolana", "Argelina", "Argentina", "Armenia", "Australiana", "Austríaca", "Bahreiní", "Belga", "Beliceña", "Beninesa",
      "Bielorusa", "Boliviana", "Botsuana", "Brasileña", "Británica", "Búlgara", "Caboverdiana", "Camboyana", "Camerunesa", "Canadiense", "Catarí", "Ceilanesa",
      "Centroafricana", "Checa", "Chilena", "Chipriota", "Colombiana", "Congoleña", "Costarricense", "Croata", "Cubana", "Danesa", "Dominicana", "Ecuatoriana", "Egipcia", "Eslovena", "Española",
      "Estadounidense", "Estonia", "Etíope", "Filipina", "Finésa", "Francesa", "Griega", "Groenlandésa", "Guatemalteca", "Haitiana", "Hondureña", "Húngara",
      "India", "Iraqí", "Irlandesa", "Islandesa", "Israelí", "Italiana", "Jamaiquina", "Japonesa", "Keniata", "Kiribatiana", "Lesotense", "Letonia", "Libanesa",
      "Lituana", "Macedonia", "Malaya", "Maltesa", "Marroquí", "Mexicana", "Moldava", "Monaquesa", "Neerlandesa", "Nicaragüense", "Nigeriana", "Norcoreana",
      "Noruega", "Omaní", "Pakistaní", "Panameña", "Paraguaya", "Peruana", "Polaca", "Portuguesa", "Rusa", "Salomonense", "Salvadoreña", "Serbia", "Singapurense",
      "Sueca", "Suiza", "Surinamesa", "Tailandesa", "Turca", "Uruguaya", "Uzbeka", "Vanuatuense", "Venezolana", "Vietnamita", "Yemení"]
  end

  def state_options(client)
    options = [["Selecciona un estado", nil]]
    options << [client.physical_client&.state] if client.physical? && client.physical_client&.state.present?
    options << [client.moral_client&.state] if client.moral? && client.moral_client&.state.present?
    options << ["Otros", "custom"]
    options
  end

  def actual_state(client)
    client.physical? ? client.physical_client&.state : client.moral_client&.state
  end

  def city_options(client)
    options = [["Selecciona una ciudad", nil]]
    options << [client.physical_client&.city] if client.physical? && client.physical_client&.city.present?
    options << [client.moral_client&.city] if client.moral? && client.moral_client&.city.present?
    options << ["Otros", "custom"]
    options
  end

  def actual_city(client)
    client.physical? ? client.physical_client&.city : client.moral_client&.city
  end

  def colony_options(client)
    options = [["Selecciona una colonia", nil]]
    options << [client.physical_client&.colony] if client.physical? && client.physical_client&.colony.present?
    options << [client.moral_client&.colony] if client.moral? && client.moral_client&.colony.present?
    options << ["Otros", "custom"]
    options
  end

  def actual_colony(client)
    client.physical? ? client.physical_client&.colony : client.moral_client&.colony
  end
end
