# frozen_string_literal: true

class Assignment < ApplicationRecord
  belongs_to :member
  belongs_to :project
end
