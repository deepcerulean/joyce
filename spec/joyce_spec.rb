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
      Application.kickstart!(headless: true)
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
  subject(:app) { Example::SampleApp.new(headless: true) }

  it 'should have a view with the indicated class' do
    expect(app.view.class).to eq(Example::SampleAppView)
  end

  context "#launch" do
    it 'should call setup' do
      expect(app).to receive(:setup)
      app.launch
    end
  end
end

describe Example::SampleAppView do
  let(:sample_app) { Example::SampleApp.new(headless: true) }
  let(:window) { instance_double(ApplicationWindow) }

  subject(:sample_app_view) { sample_app.view }
  before { sample_app.setup }

  it 'should render to the app window' do
    expect(sample_app).to receive(:window).and_return(window)
    expect(window).to receive(:draw_quad)
    sample_app_view.render
  end
end

describe Example::SampleServer, redis: true, flaky: true do
  subject(:server) { Example::SampleServer.new }
  let(:app) { Example::SampleApp.new(headless: true) }
  let(:command) { Example::PingCommand.create(player_id: 'the_player_id', player_name: 'Alice') }
  let(:event) { Example::PlayerAdmittedEvent.create(player_id: 'the_player_id', player_name: 'Alice', game_id: 'the_game_id') }

  before do
    app.launch
    server.boot
  end

  it 'should receive commands from app' do
    expect { app.fire(command); sleep 3 }.to change{server.received_commands.count}.by(1)
  end

  it 'should propagate events to app' do
    expect { server.sim.receive(event); sleep 3 }.to change{app.received_events.count}.by(1)
  end
end
