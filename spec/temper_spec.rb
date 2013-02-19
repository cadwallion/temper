require 'spec_helper'

describe Temper::PID do
  before do
    controller.setpoint = 100.0
    controller.tune 1.0, 1.0, 1.0
  end

  let(:controller) { Temper::PID.new }
  subject { controller }

  its(:kp) { should == 1.0 }
  its(:ki) { should == 1.0 }
  its(:kd) { should == 1.0 }
  its(:mode) { should == :auto }
  its(:direction) { should == :direct }

  context 'computing data' do
    before do
      controller.control 50.0
    end

    its(:output) { should == 50.0 }
  end
end
