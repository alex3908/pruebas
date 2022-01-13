
namespace :add_signature_services_to_digital_signatures do
    desc "Set Digital signature services to digital signatures"
  
    task run: :environment do
        DigitalSignature.all.each do |digital_signature|
            folder = digital_signature.folder
            digital_signature_services = folder.digital_signature_services
            if digital_signature_services.any?
                digital_signature.update_attributes!(digital_signature_service:digital_signature_services.first)
            end
        end
    end
end