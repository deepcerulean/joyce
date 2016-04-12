require 'spec_helper'

describe Joyce do
  it "should have a VERSION constant" do
    expect(subject.const_get('VERSION')).to_not be_empty
  end
end

describe Joyce::Application do
  describe '.kickstart' do
    subject(:application) { instance_double(Joyce::Application) }
    it 'should launch a new app instance' do
      expect(Application).to receive(:new).and_return(application)
      expect(application).to receive(:launch)
      Application.kickstart!
    end
  end

  describe "#launch" do
    subject(:application) { Joyce::Application.new(headless: true) }
    it 'should call #show on app window' do
      expect(application.window).to receive(:show)
      application.launch
    end
  end
end

describe Joyce::Server do
  describe ".kickstart" do
    subject(:server) { instance_double(Joyce::Server) }
    it 'should call boot on a new server instance' do
      expect(Server).to receive(:new).and_return(server)
      expect(server).to receive(:boot)
      Server.kickstart!
    end
  end
end

describe Example::SampleApp do
  it 'should have a view with the indicated class' do
    expect(subject.view.class).to eq(Example::SampleAppView)
  end
end

describe Example::SampleAppView do
  let(:sample_app) { Example::SampleApp.new }
  subject(:sample_app_view) { sample_app.view }
  it 'should render to the app window' do
    expect(sample_app.window).to receive(:draw_quad)
    sample_app_view.render
  end
end
