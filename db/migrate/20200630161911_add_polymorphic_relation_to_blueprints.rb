# frozen_string_literal: true

class AddPolymorphicRelationToBlueprints < ActiveRecord::Migration[5.2]
  def change
    add_reference :blueprints, :level, polymorphic: true
    reversible do |dir|
      dir.up { Blueprint.update_all("level_id = stage_id, level_type='Stage'") }
      dir.down { Blueprint.update_all("stage_id = level_id") }
    end
    remove_reference :blueprints, :stage, index: true, foreign_key: true
  end
end
