require_relative '../../../../lib/bookwatch/config/product_config'
require_relative '../../../../lib/bookwatch/local_filesystem_accessor'
require_relative '../../../../lib/bookwatch/subnav/navigation_entries_from_markdown_root'
require_relative '../../../../lib/bookwatch/values/output_locations'

module Bookwatch
  module Subnav
    describe NavigationEntriesFromMarkdownRoot do
      it 'returns formatted json from subnav root in a product config' do
        output_locations = OutputLocations.new(context_dir: '/')
        subnav_config = Config::ProductConfig.new({ 'subnav_root' => 'my/index' })

        fs = instance_double(Bookwatch::LocalFilesystemAccessor)

        root_index =  <<-EOT
---
title: Title for the Webz Page
---

## <a href="./cats/first-doc.html" class="subnav">First Document</a>

Some Text

## <a href="./second-doc.html" class="subnav">Second Document</a>

More text

- list item
- another list item

## <a href="./unlinked.html">My Unlinked Header</a>

## <a id='my-id'></a> My Quicklink

[A link](./third-doc.html)
        EOT

        first_doc = <<-EOT
## <a href="../nested-doc.html" class="subnav">Nested Link</a>

Some Text
        EOT

        second_doc = <<-EOT
Just some text here.
        EOT

        nested_doc = <<-EOT
Move along, nothing to see.
        EOT

        json_toc = [
          {
            url: '/my/cats/first-doc.html',
            text: 'First Document',
            nested_links: [
              {
                url: '/my/nested-doc.html',
                text: 'Nested Link'
              }
            ]
          },
          {
            url: '/my/second-doc.html',
            text: 'Second Document'
          }
        ]

        expect(fs).to receive(:find_files_extension_agnostically).
            with(Pathname('my/index'), output_locations.source_for_site_generator) { [Pathname('/output/master_middleman/source/my/index.html')] }
        expect(fs).to receive(:find_files_extension_agnostically).
            with(Pathname('my/cats/first-doc.html'), output_locations.source_for_site_generator) { [Pathname('/output/master_middleman/source/my/cats/first-doc.html.md')] }
        expect(fs).to receive(:find_files_extension_agnostically).
            with(Pathname('my/second-doc.html'), output_locations.source_for_site_generator) { [Pathname('/output/master_middleman/source/my/second-doc.html.md.erb')] }
        expect(fs).to receive(:find_files_extension_agnostically).
            with(Pathname('my/nested-doc.html'), output_locations.source_for_site_generator) { [Pathname('/output/master_middleman/source/my/nested-doc.html')] }

        allow(fs).to receive(:read).with(Pathname('/output/master_middleman/source/my/index.html')) { root_index }
        allow(fs).to receive(:read).with(Pathname('/output/master_middleman/source/my/cats/first-doc.html.md')) { first_doc }
        allow(fs).to receive(:read).with(Pathname('/output/master_middleman/source/my/second-doc.html.md.erb')) { second_doc }
        allow(fs).to receive(:read).with(Pathname('/output/master_middleman/source/my/nested-doc.html')) { nested_doc }

        expect(NavigationEntriesFromMarkdownRoot.new(fs, true).get_links(subnav_config, output_locations)).
          to eq(json_toc)
      end

      it 'returns formatted json from subnav root in a product config without checking all the links' do
        output_locations = OutputLocations.new(context_dir: '/')
        subnav_config = Config::ProductConfig.new({ 'subnav_root' => 'my/index' })

        fs = instance_double(Bookwatch::LocalFilesystemAccessor)

        root_index =  <<-EOT
---
title: Title for the Webz Page
---

## <a href="./cats/first-doc.html" class="subnav">First Document</a>

Some Text

## <a href="./second-doc.html" class="subnav">Second Document</a>

More text

- list item
- another list item

## <a href="./unlinked.html">My Unlinked Header</a>

## <a id='my-id'></a> My Quicklink

[A link](./third-doc.html)
        EOT

        first_doc = <<-EOT
## <a href="../nested-doc.html" class="subnav">Nested Link</a>

Some Text
        EOT

        second_doc = <<-EOT
Just some text here.
        EOT

        nested_doc = <<-EOT
Move along, nothing to see.
        EOT

        json_toc = [
          {
            url: '/my/cats/first-doc.html',
            text: 'First Document',
            nested_links: [
              {
                url: '/my/nested-doc.html',
                text: 'Nested Link'
              }
            ]
          },
          {
            url: '/my/second-doc.html',
            text: 'Second Document'
          }
        ]

        expect(fs).to receive(:find_files_extension_agnostically).
            with(Pathname('my/index'), output_locations.source_for_site_generator) { [Pathname('/output/master_middleman/source/my/index.html')] }
        expect(fs).to receive(:find_files_extension_agnostically).
            with(Pathname('my/cats/first-doc.html'), output_locations.source_for_site_generator) { [Pathname('/output/master_middleman/source/my/cats/first-doc.html.md')] }
        expect(fs).to receive(:find_files_extension_agnostically).
            with(Pathname('my/second-doc.html'), output_locations.source_for_site_generator) { [Pathname('/output/master_middleman/source/my/second-doc.html.md.erb')] }
        expect(fs).to receive(:find_files_extension_agnostically).
            with(Pathname('my/nested-doc.html'), output_locations.source_for_site_generator) { [Pathname('/output/master_middleman/source/my/nested-doc.html')] }

        allow(fs).to receive(:read).with(Pathname('/output/master_middleman/source/my/index.html')) { root_index }
        allow(fs).to receive(:read).with(Pathname('/output/master_middleman/source/my/cats/first-doc.html.md')) { first_doc }
        allow(fs).to receive(:read).with(Pathname('/output/master_middleman/source/my/second-doc.html.md.erb')) { second_doc }
        allow(fs).to receive(:read).with(Pathname('/output/master_middleman/source/my/nested-doc.html')) { nested_doc }

        expect(NavigationEntriesFromMarkdownRoot.new(fs, false).get_links(subnav_config, output_locations)).
          to eq(json_toc)
      end

      it 'raises an error if a link is included twice in a subnav' do
        output_locations = OutputLocations.new(context_dir: '/')
        subnav_config = Config::ProductConfig.new({ 'subnav_root' => 'my/index' })

        fs = instance_double(Bookwatch::LocalFilesystemAccessor)

        root_index =  <<-EOT
---
title: Title for the Webz Page
---

## <a href="./first-doc.html" class="subnav">First Document</a>

Some Text
        EOT

        first_doc = <<-EOT
## <a href="./index.html" class="subnav">Nested Link</a>

Some Text
        EOT

        expect(fs).to receive(:find_files_extension_agnostically).
            with(Pathname('my/index'), output_locations.source_for_site_generator) { [Pathname('/output/master_middleman/source/my/index.html')] }
        expect(fs).to receive(:find_files_extension_agnostically).
            with(Pathname('my/index.html'), output_locations.source_for_site_generator) { [Pathname('/output/master_middleman/source/my/index.html')] }
        expect(fs).to receive(:find_files_extension_agnostically).
            with(Pathname('my/first-doc.html'), output_locations.source_for_site_generator) { [Pathname('/output/master_middleman/source/my/first-doc.extension')] }

        allow(fs).to receive(:read).with(Pathname('/output/master_middleman/source/my/index.html')) { root_index }
        allow(fs).to receive(:read).with(Pathname('/output/master_middleman/source/my/first-doc.extension')) { first_doc }

        expect { NavigationEntriesFromMarkdownRoot.new(fs, true).get_links(subnav_config, output_locations) }.
          to raise_error(NavigationEntriesFromMarkdownRoot::SubnavDuplicateLinkError) do |error|
            expect(error.message).to include('my/index.html')
        end
      end

      it 'raises an error if a link goes to a bogus place' do
        output_locations = OutputLocations.new(context_dir: '/')
        subnav_config = Config::ProductConfig.new({ 'subnav_root' => 'my/index' })

        fs = instance_double(Bookwatch::LocalFilesystemAccessor)

        root_index =  <<-EOT
---
title: Title for the Webz Page
---

## <a href="./bogus-doc.html" class="subnav">Bogus Document</a>

Some Text
        EOT

        expect(fs).to receive(:find_files_extension_agnostically).
            with(Pathname('my/index'), output_locations.source_for_site_generator) { [Pathname('/output/master_middleman/source/my/index.html')] }
        expect(fs).to receive(:find_files_extension_agnostically).
            with(Pathname('my/bogus-doc.html'), output_locations.source_for_site_generator) { [] }

        allow(fs).to receive(:read).with(Pathname('/output/master_middleman/source/my/index.html')) { root_index }

        expect { NavigationEntriesFromMarkdownRoot.new(fs, true).get_links(subnav_config, output_locations) }.
          to raise_error(NavigationEntriesFromMarkdownRoot::SubnavBrokenLinkError) do |error|
          expect(error.message).to include('my/bogus-doc.html')
        end
      end

      it 'can include broken subnav links when told' do
        output_locations = OutputLocations.new(context_dir: '/')
        subnav_config = Config::ProductConfig.new({ 'subnav_root' => 'my/index' })

        fs = instance_double(Bookwatch::LocalFilesystemAccessor)

        root_index =  <<-EOT
---
title: Title for the Webz Page
---

## <a href="./bogus-doc.html" class="subnav">Bogus Document</a>

Some Text
        EOT

        json_toc = [
          {
            url: '/my/bogus-doc.html',
            text: 'Bogus Document'
          }
        ]

        expect(fs).to receive(:find_files_extension_agnostically).
          with(Pathname('my/index'), output_locations.source_for_site_generator) { [Pathname('/output/master_middleman/source/my/index.html')] }
        expect(fs).to receive(:find_files_extension_agnostically).
          with(Pathname('my/bogus-doc.html'), output_locations.source_for_site_generator) { [] }

        allow(fs).to receive(:read).with(Pathname('/output/master_middleman/source/my/index.html')) { root_index }

        expect(NavigationEntriesFromMarkdownRoot.new(fs, false).get_links(subnav_config, output_locations)).to eq(json_toc)
      end

      it 'barfs informatively if it cannot find a subnav root' do
        output_locations = OutputLocations.new(context_dir: '/')
        subnav_config = Config::ProductConfig.new({ 'subnav_root' => 'my/index' })

        fs = instance_double(Bookwatch::LocalFilesystemAccessor)

        expect(fs).to receive(:find_files_extension_agnostically).with(Pathname('my/index'), output_locations.source_for_site_generator){[]}

        expect { NavigationEntriesFromMarkdownRoot.new(fs, true).get_links(subnav_config, output_locations) }.to raise_error(NavigationEntriesFromMarkdownRoot::SubnavRootMissingError)
      end

      it 'can generate an empty subnav if it cannot find a subnav root' do
        output_locations = OutputLocations.new(context_dir: '/')
        subnav_config = Config::ProductConfig.new({ 'subnav_root' => 'my/index' })

        fs = instance_double(Bookwatch::LocalFilesystemAccessor)

        expect(fs).to receive(:find_files_extension_agnostically).with(Pathname('my/index'), output_locations.source_for_site_generator){[]}

        expect(NavigationEntriesFromMarkdownRoot.new(fs, false).get_links(subnav_config, output_locations)).to eq([])
      end
    end
  end
end
