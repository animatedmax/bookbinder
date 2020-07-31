require_relative '../../../../lib/bookwatch/subnav/navigation_entries_from_html_toc'
require_relative '../../../../lib/bookwatch/local_filesystem_accessor'
require_relative '../../../../lib/bookwatch/values/section'
require_relative '../../../../lib/bookwatch/values/output_locations'

module Bookwatch
  module Subnav
    describe NavigationEntriesFromHtmlToc do
      describe 'formatting a subnav' do
        let(:toc_html) { <<-EOT
<html>
  <body>
    <ul>
        <li><a href="common/topics/pivotal-copyright.html">Copyright</a></li>
        <li><a href="release-notes/release-notes.html">A. Pivotal GemFire XD 1.4 Release Notes</a>
            <ul>
                <li><a href="release-notes/release-notes-gemfirexd-1.4.0.html">A.i. Pivotal GemFire XD 1.4.0 Release Notes</a></li>
            </ul>
        </li>
        <li><a href="http://example.com">External link</a></li>
        <li><a href="https://example.com">Https External link</a></li>
    </ul>
  </body>
</html>
        EOT
        }

        let(:expected_navigation) {
          [
            {
              url: "/go-here-please/common/topics/pivotal-copyright.html",
              text: "Copyright"
            },
            {
              url: "/go-here-please/release-notes/release-notes.html",
              text: "A. Pivotal GemFire XD 1.4 Release Notes",
              nested_links: [
                {
                  url: "/go-here-please/release-notes/release-notes-gemfirexd-1.4.0.html",
                  text: "A.i. Pivotal GemFire XD 1.4.0 Release Notes"
                }
              ]
            },
            {
              url: "http://example.com",
              text: "External link"
            },
            {
              url: "https://example.com",
              text: "Https External link"
            }
          ]
        }

        it 'applies the appropriate CSS classes, wraps divs, and creates anchor paths from root' do
          section = Section.new(
            '',
            '',
            'go-here-please'
          )
          output_locations = OutputLocations.new(context_dir: '.')

          fs = instance_double('Bookwatch::LocalFilesystemAccessor')
          expect(fs).to receive(:read).with(
              File.join(output_locations.html_from_preprocessing_dir,'go-here-please','index.html')
          ) { toc_html }

          expect(NavigationEntriesFromHtmlToc.new(fs).get_links(section, output_locations)).to eq(expected_navigation)
        end
      end
    end
  end
end
