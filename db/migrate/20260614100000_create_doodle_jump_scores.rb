# frozen_string_literal: true

class CreateDoodleJumpScores < ActiveRecord::Migration[7.2]
  def change
    create_table :doodle_jump_scores do |t|
      t.integer :user_id, null: false
      t.integer :score, null: false
      t.timestamps
    end

    add_index :doodle_jump_scores, :user_id, unique: true
    add_index :doodle_jump_scores, %i[score updated_at]
  end
end
