require 'tmpdir'
require 'yaml'
require_relative '../helpers/git_repo'
require_relative '../helpers/redirection'

describe 'binding a book remotely' do
  include Bookwatch::GitRepo
  include Bookwatch::Redirection

  let(:gem_root) { File.expand_path('../../../', __FILE__) }

  it 'includes content from a remote section' do
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do

        Dir.mkdir('master_middleman')

        init_repo(at_dir: 'some-section',
                  contents: 'My cat fell in the canal again.',
                  file: 'index.html.erb')

        File.write('./config.yml', YAML.dump('book_repo' => 'does-not/matter',
                                             'public_host' => 'does-not-matter.foo.com',
                                             'sections' => [
                                                 'repository' => {
                                                     'name' => File.absolute_path('some-section')
                                                 }
                                             ]))

        `#{gem_root}/install_bin/bookwatch bind remote`

        expect(File.read("#{dir}/final_app/public/some-section/index.html")).to include('My cat fell in the canal again.')
      end
    end
  end
end
