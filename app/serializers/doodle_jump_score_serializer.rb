# frozen_string_literal: true

class DoodleJumpScoreSerializer < ApplicationSerializer
  attributes :id, :user_id, :username, :name, :avatar_template, :score, :updated_at

  def id
    object.user_id
  end

  def username
    object.user.username
  end

  def name
    object.user.name
  end

  def avatar_template
    object.user.avatar_template
  end

  def include_name?
    object.user.name.present?
  end
end
