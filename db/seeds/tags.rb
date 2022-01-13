# frozen_string_literal: true

settings = Setting.where(key: ["project_singular", "phase_singular", "stage_singular"])
@project_singular = settings.select { |setting| setting.key == "project_singular" }.first&.value || "Proyecto"
@phase_singular = settings.select { |setting| setting.key == "phase_singular" }.first&.value || "Fase"
@stage_singular = settings.select { |setting| setting.key == "stage_singular" }.first&.value || "Etapa"

Tag.create_with(name: "al/a la señor(a)").find_or_create_by(key: "al-senor")
Tag.create_with(name: "el/la señor(a)").find_or_create_by(key: "el-senor")
Tag.create_with(name: "Nombre completo").find_or_create_by(key: "nombre-completo-cliente")
Tag.create_with(name: "Primer apellido").find_or_create_by(key: "primer-apellido-cliente")
Tag.create_with(name: "Segundo apellido").find_or_create_by(key: "segundo-apellido-cliente")
Tag.create_with(name: "Nombre(s)").find_or_create_by(key: "nombres-cliente")
Tag.create_with(name: "Correo del cliente").find_or_create_by(key: "correo-cliente")
Tag.create_with(name: "Nombre del #{@project_singular.downcase}").find_or_create_by(key: "nombre-proyecto")
lot_name = Tag.create_with(name: "Número del lote").find_or_create_by(key: "numero-de-lote")
lot_area = Tag.create_with(name: "Superficie del lote").find_or_create_by(key: "superficie-de-lote")
Tag.create_with(name: "Mensualidades totales").find_or_create_by(key: "mensualidades-totales")
Tag.create_with(name: "Precio por metro cuadrado con números").find_or_create_by(key: "precio-metro-con-numeros")
Tag.create_with(name: "Precio por metro cuadrado con letras").find_or_create_by(key: "precio-metro-con-letras")
Tag.create_with(name: "Precio por metro cuadrado con descuento con números").find_or_create_by(key: "precio-metro-con-descuento-con-numeros")
Tag.create_with(name: "Precio por metro cuadrado con descuento con letras").find_or_create_by(key: "precio-metro-con-descuento-con-letras")
Tag.create_with(name: "Anticipo con números").find_or_create_by(key: "anticipo-con-numeros")
Tag.create_with(name: "Anticipo con letras").find_or_create_by(key: "anticipo-con-letras")
Tag.create_with(name: "Saldo de enganche con números").find_or_create_by(key: "saldo-enganche-con-numeros")
Tag.create_with(name: "Saldo de enganche con letras").find_or_create_by(key: "saldo-enganche-con-letras")
Tag.create_with(name: "Enganche total con números").find_or_create_by(key: "enganche-con-numeros")
Tag.create_with(name: "Enganche total con letras").find_or_create_by(key: "enganche-con-letras")
Tag.create_with(name: "Monto a financiar con números").find_or_create_by(key: "saldo-total-con-numeros")
Tag.create_with(name: "Monto a financiar con letras").find_or_create_by(key: "saldo-total-con-letras")
Tag.create_with(name: "Precio con letras").find_or_create_by(key: "precio-con-letras")
Tag.create_with(name: "Precio con tipo de moneda").find_or_create_by(key: "precio-con-numeros")
Tag.create_with(name: "Estado civil").find_or_create_by(key: "estado-civil")
Tag.create_with(name: "Ocupación").find_or_create_by(key: "ocupacion-cliente")
Tag.create_with(name: "Número de casa").find_or_create_by(key: "numero-de-casa")
Tag.create_with(name: "Calle").find_or_create_by(key: "calle")
Tag.create_with(name: "Colonia").find_or_create_by(key: "colonia")
Tag.create_with(name: "Código postal").find_or_create_by(key: "codigo-postal")
Tag.create_with(name: "Localidad").find_or_create_by(key: "localidad")
Tag.create_with(name: "Ciudad").find_or_create_by(key: "ciudad")
Tag.create_with(name: "Estado").find_or_create_by(key: "estado")
Tag.create_with(name: "País").find_or_create_by(key: "pais")
Tag.create_with(name: "Nacionalidad").find_or_create_by(key: "nacionalidad")
Tag.create_with(name: "Lugar de nacimiento").find_or_create_by(key: "lugar-de-nacimiento")
Tag.create_with(name: "Fecha de nacimiento").find_or_create_by(key: "fecha-de-nacimiento")
Tag.create_with(name: "Tipo de identificación").find_or_create_by(key: "tipo-de-identificacion")
Tag.create_with(name: "Institución expedidora").find_or_create_by(key: "institucion-expedidora")
Tag.create_with(name: "Número de identificación").find_or_create_by(key: "numero-de-identificacion")
Tag.create_with(name: "CURP").find_or_create_by(key: "curp")
Tag.create_with(name: "RFC").find_or_create_by(key: "rfc")
Tag.create_with(name: "Fecha actual").find_or_create_by(key: "fecha-actual")
Tag.create_with(name: "Día actual").find_or_create_by(key: "dia-actual")
Tag.create_with(name: "Mes actual").find_or_create_by(key: "mes-actual")
Tag.create_with(name: "Año actual").find_or_create_by(key: "anio-actual")
Tag.create_with(name: "Fecha de reserva").find_or_create_by(key: "fecha-reserva")
Tag.create_with(name: "Día de reserva").find_or_create_by(key: "dia-reserva")
Tag.create_with(name: "Mes de reserva").find_or_create_by(key: "mes-reserva")
Tag.create_with(name: "Año de reserva").find_or_create_by(key: "anio-reserva")
Tag.create_with(name: "Fecha a 5 años posteriores").find_or_create_by(key: "fecha-cinco-anios")
phase_name = Tag.create_with(name: "Nombre de #{@phase_singular.downcase}").find_or_create_by(key: "nombre-fase")
stage_name = Tag.create_with(name: "Nombre de #{@stage_singular.downcase}").find_or_create_by(key: "nombre-etapa")
Tag.create_with(name: "Mensualidades sin intereses").find_or_create_by(key: "mensualidades-sin-intereses")
Tag.create_with(name: "Mensualidades con intereses").find_or_create_by(key: "mensualidades-con-intereses")
Tag.create_with(name: "Número de pagos en periodo 0%").find_or_create_by(key: "pagos-1")
Tag.create_with(name: "Amortización periodo 0%").find_or_create_by(key: "amortizacion-1")
Tag.create_with(name: "Amortización periodo 0% con letras").find_or_create_by(key: "amortizacion-letras-1")
Tag.create_with(name: "Número de pagos en periodo 1%").find_or_create_by(key: "pagos-2")
Tag.create_with(name: "Amortización periodo 1%").find_or_create_by(key: "amortizacion-2")
Tag.create_with(name: "Amortización periodo 1% con letras").find_or_create_by(key: "amortizacion-letras-2")
Tag.create_with(name: "Número de pagos en periodo 1.25%").find_or_create_by(key: "pagos-3")
Tag.create_with(name: "Amortización periodo 1.25%").find_or_create_by(key: "amortizacion-3")
Tag.create_with(name: "Amortización periodo 1.25% con letras").find_or_create_by(key: "amortizacion-letras-3")
Tag.create_with(name: "Prefijo compuesto del lote").find_or_create_by(key: "prefijo-compuesto-lote")
Tag.create_with(name: "RFC de representante legal").find_or_create_by(key: "rfc-representante-legal")
Tag.create_with(name: "Nombre de representante legal").find_or_create_by(key: "nombre-representante-legal")
Tag.create_with(name: "Nombre del notario").find_or_create_by(key: "nombre-notario")
Tag.create_with(name: "Nombre de la empresa").find_or_create_by(key: "nombre-empresa")

Tag.create_with(name: "Norte").find_or_create_by(related_to: "lots", key: "norte")
Tag.create_with(name: "Sur").find_or_create_by(related_to: "lots", key: "sur")
Tag.create_with(name: "Éste").find_or_create_by(related_to: "lots", key: "este")
Tag.create_with(name: "Oeste").find_or_create_by(related_to: "lots", key: "oeste")
Tag.create_with(name: "Colinda con (Norte)").find_or_create_by(related_to: "lots", key: "colinda-norte")
Tag.create_with(name: "Colinda con (Sur)").find_or_create_by(related_to: "lots", key: "colinda-sur")
Tag.create_with(name: "Colinda con (Éste)").find_or_create_by(related_to: "lots", key: "colinda-este")
Tag.create_with(name: "Colinda con (Oeste)").find_or_create_by(related_to: "lots", key: "colinda-oeste")
lot_area.update!(related_to: "all")
lot_name.update!(related_to: "all")
phase_name.update!(related_to: "all")
stage_name.update!(related_to: "all")
