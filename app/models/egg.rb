class Egg < ActiveRecord::Base
  belongs_to :location
  belongs_to :user

  SIZES = [{ desc: "ant", value: 1},
           { desc: "pigeon", value: 2},
           { desc: "chicken", value: 3},
           { desc: "goose", value: 4},
           { desc: "ostrich", value: 5},
           { desc: "dragon", value: 6}]

  validates :size, presence: true, inclusion: { in: (SIZES.collect {|s| s[:value]}),
                                                message: "%{value} is not a valid size: #{(SIZES.collect {|s| s[:value]}).join(",")}"
                                               }
  validates :name, presence: true, length: { in: 3..250 }
  validates :location, presence: true
  validates :user, presence: true

  def size_to_s
    (SIZES.select {|s| s[:value] == self.size}).first[:desc]
  end  

  def name=(name)
    super(name.to_s.strip)
  end  
end
