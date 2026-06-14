# frozen_string_literal: true

class CreateDoodleJumpScores < ActiveRecord::Migration[8.0]
  USER_INDEX = "index_doodle_jump_scores_on_user_id"
  RANKING_INDEX = "index_doodle_jump_scores_on_score_and_updated_at"

  def up
    if table_exists?(:doodle_jump_scores)
      ensure_indexes
      return
    end

    create_table :doodle_jump_scores do |t|
      t.integer :user_id, null: false
      t.integer :score, null: false
      t.timestamps
    end

    ensure_indexes
  end

  def down
    drop_table :doodle_jump_scores, if_exists: true
  end

  private

  def ensure_indexes
    return unless table_exists?(:doodle_jump_scores)

    unless index_exists?(:doodle_jump_scores, :user_id, name: USER_INDEX)
      add_index :doodle_jump_scores, :user_id, unique: true, name: USER_INDEX
    end

    unless index_exists?(:doodle_jump_scores, %i[score updated_at], name: RANKING_INDEX)
      add_index :doodle_jump_scores, %i[score updated_at], name: RANKING_INDEX
    end
  end
end
