# bowling_spec.rb
require './models/timeline'

describe Timeline, "#add" do
  it "adds even to timeline" do
    timeline=Timeline.new
    
    today=Time.now
    timeline.add(today, 3, :follow, 4)
    timeline.add(today, 3, :unfollowed, 5);
    
    timeline.length.should eq(2)

  end
end

# rspec bowling_spec.rb --format nested