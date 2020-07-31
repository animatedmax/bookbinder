require 'tmpdir'
require_relative '../../../../lib/bookwatch/config/configuration_decorator'
require_relative '../../../../lib/bookwatch/values/section'

module Bookwatch
  module Config
    describe ConfigurationDecorator do
      let(:loader) { double('config loader') }
      let(:base_config) { Configuration.parse('archive_menu' => ['v2', {'v1' => 'some/place'}]) }
      let(:config_decorator){ ConfigurationDecorator.new(loader: loader, config_filename: 'iampresent.yml') }

      context "when repo_links are enabled" do
        it "generates configuration mapping section desired dirs to repo names and refs" do
          config_decorator = ConfigurationDecorator.new(loader: loader, config_filename: 'iampresent.yml')
          base_config = Configuration.parse('repo_link_enabled' => true)
          sections = [Section.new('must/be-github', nil, 200, nil, nil, nil, 'special/path', 'our-org/repo', 'our-ref')]
          expected_config = Configuration.parse(
            'repo_link_enabled' => true,
            'repo_links' => {
              '200' => {
                'repo' => 'our-org/repo',
                'ref' => 'our-ref',
                'at_path' => 'special/path'
              }
            },
            'archive_menu' => {
              '.' => nil
            }
          )

          allow(loader).to receive(:load_key).
              with(Pathname('must/be-github/special/path').join('iampresent.yml'), 'archive_menu') {}

          expect(config_decorator.generate(base_config, sections)).to eq(expected_config)
        end
      end

      context "when dir repo links are not enabled" do
        it "doesn't generate configuration mapping section desired dirs to repo names" do
          base_config = Configuration.parse('repo_link_enabled' => false)
          sections = [Section.new('must/be-github', nil, 'go here!!!', nil, nil, nil, nil, 'our-org/repo')]
          expected_config = Configuration.parse(
            'repo_link_enabled' => false,
            'repo_links' => nil,
            'archive_menu' => {
              '.' => nil
            }
          )
          allow(loader).to receive(:load_key).
              with(Pathname('must/be-github').join('iampresent.yml'), 'archive_menu') {}

          expect(config_decorator.generate(base_config, sections)).to eq(expected_config)
        end

      end

      context "when a section has its own menu config" do
        it "generates configuration for that section" do
          dir = 'some/path'
          sections = [Section.new(dir, nil, 'my/dir')]

          allow(loader).
            to receive(:load_key).
            with(Pathname(dir).join('iampresent.yml'), 'archive_menu') {
              ['v1', {'v0.9' => 'section/place'}]
            }

          expect(config_decorator.generate(base_config, sections)).to eq(
            Configuration.parse(
              'archive_menu' => {
                '.' => base_config.archive_menu,
                'my/dir' => ['v1', {'v0.9' => 'section/place'}]
              },
              'repo_links' => nil
            ))
        end
      end

      context "when a section doesn't have its own menu config" do
        it "doesn't generate configuration for that section" do
          config_decorator = ConfigurationDecorator.new(
            loader: loader,
            config_filename: 'uncheckedfn.yml'
          )
          sections = [Section.new('not/tested', nil, nil, 'wont/appear')]

          allow(loader).to receive(:load_key) { nil }

          expect(config_decorator.generate(base_config, sections)).to eq(
            Configuration.parse(
            'archive_menu' => {
              '.' => base_config.archive_menu
            },
            'repo_links' => nil))
        end
      end
    end
  end
end
