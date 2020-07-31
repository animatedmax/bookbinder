require_relative '../fixtures/repo_fixture'
require_relative 'tmp_dirs'

def use_fixture_repo(repo_name = 'book')
  include_context 'tmp_dirs'

  around do |spec|
    # temp_library = tmp_subdir 'repositories'
    Dir.mktmpdir('repositories') do |temp_library|
      FileUtils.cp_r File.join(Bookwatch::RepoFixture.repos_dir, '.'), temp_library
      # puts File.join(temp_library, repo_name)
      FileUtils.cd(File.join(temp_library, repo_name)) do
        spec.run
      end
    end
  end
end

def before_all_in_fixture_repo(repo_name, &block)
  before(:all) do
    temp_library = tmp_subdir 'repositories'
    FileUtils.cp_r File.join(Bookwatch::RepoFixture.repos_dir, '.'), temp_library
    FileUtils.cd(File.join(temp_library, 'archive-menu-book')) do
      block.call
    end
  end
end
