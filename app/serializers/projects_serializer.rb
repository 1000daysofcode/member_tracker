# frozen_string_literal: true

class ProjectsSerializer
  def initialize(projects)
    @projects = projects
  end

  def as_json
    @projects.map { |project| { name: project.name } }
  end

  private

  attr_reader :projects
end
