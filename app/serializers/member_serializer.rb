# frozen_string_literal: true

class MemberSerializer
  def initialize(member)
    @member = member
  end

  def as_json
    {
      name: member_name,
      city: @member.city,
      state: @member.state,
      country: @member.country,
      team: Team.find_by(id: @member.team_id).name,
      projects: Member.first.projects.map(&:name)
    }
  end

  private

  attr_reader :members

  def member_name
    "#{@member.first_name} #{@member.last_name}"
  end
end
