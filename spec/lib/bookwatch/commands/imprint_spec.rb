require_relative '../../../../lib/bookwatch/commands/imprint'
# Values
require_relative '../../../../lib/bookwatch/sheller'
require_relative '../../../../lib/bookwatch/values/output_locations'
require_relative '../../../../lib/bookwatch/config/section_config'
require_relative '../../../../lib/bookwatch/config/configuration'
require_relative '../../../../lib/bookwatch/values/section'
require_relative '../../../../lib/bookwatch/streams/filter_stream'
# Doubles
require_relative '../../../../lib/bookwatch/ingest/cloner_factory'
require_relative '../../../../lib/bookwatch/ingest/git_cloner'
require_relative '../../../../lib/bookwatch/preprocessing/preprocessor'
require_relative '../../../../lib/bookwatch/ingest/section_repository'
require_relative '../../../../lib/bookwatch/commands/components/imprint/directory_preparer'
require_relative '../../../../lib/bookwatch/config/fetcher'

module Bookwatch
  describe Commands::Imprint do
    it 'prepares directories and then preprocesses fetched sections' do
      base_streams = { success: double('stream').as_null_object }
      merged_streams = base_streams.merge({ out: instance_of(Streams::FilterStream) })
      output_locations = OutputLocations.new(context_dir: ".")
      section_config = Config::SectionConfig.new({'directory' => 'foo'})
      config = Config::Configuration.new({book_repo: "some_book", sections: [section_config]})

      cloner_factory = instance_double(Ingest::ClonerFactory)
      cloner = instance_double(Ingest::GitCloner)
      allow(cloner_factory).to receive(:produce).with(File.expand_path('..')) { cloner}

      preprocessor = instance_double(Preprocessing::Preprocessor)

      sections = [Section.new('fake/path', 'foo/bar'), Section.new('other/path', 'cat/dog')]

      section_repository = instance_double(Ingest::SectionRepository)
      allow(section_repository).to receive(:fetch).with(
          configured_sections: [section_config],
          destination_dir: output_locations.cloned_preprocessing_dir,
          ref_override: nil,
          cloner: cloner,
          streams: base_streams
        ) { sections }

      directory_preparer = instance_double(Commands::Components::Imprint::DirectoryPreparer)
      expect(directory_preparer).to receive(:prepare_directories).with(output_locations).ordered

      expect(preprocessor).to receive(:preprocess).with(
          sections,
          output_locations,
          options: { dita_flags: nil },
          output_streams: merged_streams,
          config: config
        ).ordered

      Commands::Imprint.new(
        base_streams,
        output_locations: output_locations,
        config_fetcher: instance_double(Config::Fetcher, fetch_config: config),
        preprocessor: preprocessor,
        cloner_factory: cloner_factory,
        section_repository: section_repository,
        directory_preparer: directory_preparer
      ).run('local')
    end
  end
end
