require_relative '../../../../lib/bookwatch/local_filesystem_accessor'
require_relative '../../../../lib/bookwatch/subnav/pdf_config_creator'
require_relative '../../../../lib/bookwatch/values/output_locations'
require_relative '../../../../lib/bookwatch/config/product_config'

module Bookwatch
  module Subnav
    describe PdfConfigCreator do
      it 'creates a yaml with a page for each link in json props file' do
        config = Config::ProductConfig.new({'pdf_config' => 'my-pdf.yml'})
        output_locations = OutputLocations.new(context_dir: '.')

        navigation_entries = [
          {url: '/annie/dog.html'},
          {url: '/sophie/pup.html'},
          {text: 'ignore me'},
          {url: 'yuki/pooch.html'}
        ]

        pdf_yml = <<-EOT
---
copyright_notice: REPLACE ME
header: REPLACE ME
executable: REPLACE ME
pages:
- annie/dog.html
- sophie/pup.html
- yuki/pooch.html
        EOT

        fs = instance_double(Bookwatch::LocalFilesystemAccessor)

        expect(fs).to receive(:overwrite).with(to: output_locations.pdf_config_dir.join('my-pdf.yml'), text: pdf_yml)

        PdfConfigCreator.new(fs, output_locations).create(navigation_entries, config)
      end
    end
  end
end
