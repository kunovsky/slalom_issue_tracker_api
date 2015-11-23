class SlalomResource < ActiveRecord::Base

  def self.create_slalom_resources_from_request(resources)
    resources.each do |resource|
      puts resource.inspect
      SlalomResource.create!(
        name: resource["name"],
        email: resource["email"],
        hourly_rate: resource["hourly_rate"]
      )
    end
  end

  def as_json(options=nil)
    super(:only => [:id, :name, :email, :hourly_rate])
  end
end
