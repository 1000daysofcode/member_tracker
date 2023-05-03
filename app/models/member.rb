# frozen_string_literal: true

class Member < ApplicationRecord
  validates :first_name, :last_name, presence: true, length: { minimum: 2, maximum: 20 }
  validates :city, :state, length: { minimum: 3, maximum: 20 }
  validates :country, presence: true, length: { minimum: 3, maximum: 30 }

  has_one :team, dependent: false
  has_many :assignments, dependent: false
  has_many :projects, through: :assignments
end
