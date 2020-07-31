describe 'calling bookwatch with --version' do
  let(:gem_root) { File.expand_path('../../../', __FILE__) }
  let(:version) { Gem::Specification::load(File.join gem_root, "bookwatch.gemspec").version }

  it 'outputs the version' do
    expect(`#{gem_root}/install_bin/bookwatch --version`).to eq("bookwatch #{version}\n")
  end
end
