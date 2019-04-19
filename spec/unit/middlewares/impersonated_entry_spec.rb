require 'spec_helper'

require_relative '../../../lib/locomotive/steam/middlewares/concerns/helpers'
require_relative '../../../lib/locomotive/steam/middlewares/concerns/auth_helpers'
require_relative '../../../lib/locomotive/steam/middlewares/thread_safe'
require_relative '../../../lib/locomotive/steam/middlewares/impersonated_entry'

describe Locomotive::Steam::Middlewares::ImpersonatedEntry do

  let(:site)            { instance_double('Site', _id: 42) }
  let(:url)             { 'http://models.example.com' }
  let(:app)             { ->(env) { [200, env, ['<html><body></body></html>']] } }
  let(:entry)           { nil }
  let(:session)         { {} }
  let(:params)          { {} }
  let(:middleware)      { described_class.new(app) }

  subject do
    env = env_for(url, params: params)
    env['rack.session']               = session
    env['steam.site']                 = site
    env['steam.request']              = Rack::Request.new(env)
    env['steam.liquid_assigns']       = {}
    env['steam.authenticated_entry']  = entry
    code, env, body = middleware.call(env)
    [env['steam.impersonating_authenticated_entry'], body.first]
  end

  describe 'no impersonation' do

    it { is_expected.to eq [nil, '<html><body></body></html>'] }

  end

  describe 'impersonating is on' do

    let(:session) { { authenticated_impersonation: '1', authenticated_entry_type: 'accounts' } }

    context 'the account is not logged in' do

      it { is_expected.to eq [nil, '<html><body></body></html>'] }

    end

    context 'the account is logged in' do

      let(:entry) { instance_double('Account', _label: 'John') }

      it { expect(subject.first).to eq true }
      it { expect(subject.last.gsub(/\s*\n\s+/, ' ')).to include('<body><div class="locomotive-impersonating-banner" ') }

    end

    describe 'the administrator wants to leave the impersonating mode' do

      let(:entry) { instance_double('Account', _label: 'John') }
      let(:params) { { impersonating: 'stop' } }

      it { is_expected.to eq [nil, '<html><body></body></html>'] }

    end

  end

end
