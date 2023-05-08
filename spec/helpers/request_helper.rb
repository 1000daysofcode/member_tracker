# frozen_string_literal: true

module RequestHelper
  def response_body
    JSON.parse(response.body)
  end

  def first_response
    {
      'name' => 'Bill Bob',
      'city' => 'Yale',
      'state' => 'Connecticut',
      'country' => 'USA',
      'team' => 'Test Team',
      'projects' => []
    }
  end

  def second_response
    {
      'name' => 'Jenny Gump',
      'city' => 'New Orleans',
      'state' => 'Louisiana',
      'country' => 'USA',
      'team' => 'Test Team',
      'projects' => []
    }
  end
end
