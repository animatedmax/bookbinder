require_relative '../../../../lib/bookwatch/config/product_config'

module Bookwatch
  module Config
    describe ProductConfig do
      it 'can return a product id' do
        config = {'id' => 'my_product'}

        expect(ProductConfig.new(config).id).
          to eq('my_product')
      end

      it 'can return a product id as subnav name' do
        config = {'id' => 'my_product'}

        expect(ProductConfig.new(config).subnav_name).
            to eq('my_product')
      end

      it 'can return a pdf config name' do
        config = {'pdf_config' => 'mypdfconfig'}

        expect(ProductConfig.new(config).pdf_config).
          to eq('mypdfconfig')
      end

      it 'can return a subnav root' do
        config = {'subnav_root' => 'some/file/path'}

        expect(ProductConfig.new(config).subnav_root).
          to eq('some/file/path')
      end

      it 'is valid with required keys' do
        config = { 'id' => 'elena'}

        expect(ProductConfig.new(config).valid?).to be(true)
      end

      it 'is not valid when missing required keys' do
        config = {}

        expect(ProductConfig.new(config).valid?).to be(false)
      end
    end
  end
end
