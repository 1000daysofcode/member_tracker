# frozen_string_literal: true

class Team < ApplicationRecord
  belongs_to :member, optional: true
end
