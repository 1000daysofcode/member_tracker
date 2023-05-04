# frozen_string_literal: true

class TeamsSerializer
  def initialize(teams)
    @teams = teams
  end

  def as_json
    @teams.map { |team| { name: team.name } }
  end

  private

  attr_reader :teams
end
