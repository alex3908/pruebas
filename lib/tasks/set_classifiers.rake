namespace :set_classifiers do
    desc "ensure backward compatibility of classifiers"
  
    task run: :environment do   
      User.all.each do |user|
        sql = "SELECT classifier_id from classifiers_users cu where cu.user_id = #{user.id}"
        execute_sql(sql).each do |classifier|
            ClassifierUser.create!(classifier_id: classifier[0], user: user)
        end
      end

      Role.all.each do |role|
        sql = "SELECT classifier_id from classifiers_roles cr where cr.role_id = #{role.id}"
        execute_sql(sql).each do |classifier|
            ClassifierRole.create!(classifier_id: classifier[0], role: role)
        end
      end
    end

    def execute_sql(sql)
        result = ActiveRecord::Base.connection.execute(sql)
        result.values
    end
  end
  