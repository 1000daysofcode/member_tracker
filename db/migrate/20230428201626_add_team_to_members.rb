# frozen_string_literal: true

class AddTeamToMembers < ActiveRecord::Migration[7.0]
  def change
    add_reference :members, :team, null: false, foreign_key: true, default: 'No Assigned Team'
  end
end
