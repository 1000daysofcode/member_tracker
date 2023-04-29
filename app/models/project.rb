# frozen_string_literal: true

class Project < ApplicationRecord
  has_many :assignments, dependent: false
  has_many :members, through: :assignments
end
