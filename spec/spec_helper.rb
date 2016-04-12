require 'rspec'
require 'joyce/version'
require 'joyce'

include Joyce

module Example
  class SampleAppView < Joyce::ApplicationView
    def render
      window.draw_quad(10,10, 0xf0f0f0f0,
                       10,20, 0xf0f0f0f0,
                       20,10, 0xf0f0f0f0,
                       20,20, 0xf0f0f0f0)
    end
  end

  class SampleApp < Joyce::Application
    viewed_with Example::SampleAppView
  end
end
