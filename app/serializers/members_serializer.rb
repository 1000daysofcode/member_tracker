# frozen_string_literal: true

class MembersSerializer
  def initialize(members)
    @members = members
  end

  def as_json
    @members.map do |member|
      {
        name: name(member),
        city: member.city,
        state: member.state,
        country: member.country,
        team: Team.find_by(id: member.team_id).name,
        projects: Member.first.projects.map(&:name)
      }
    end
  end

  private

  attr_reader :members

  def name(member)
    "#{member.first_name} #{member.last_name}"
  end
end
