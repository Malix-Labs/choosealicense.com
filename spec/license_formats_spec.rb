# frozen_string_literal: true

require 'spec_helper'

describe 'license formats' do
  licenses.each do |license|
    context "The #{license['title']} license" do
      let(:spdx_lcase) { license['spdx-lcase'] }
      
      context 'format files' do
        it 'should have a plain text version' do
          file_path = "_site/licenses/#{spdx_lcase}/index.txt"
          expect(File.exist?(file_path)).to be true, "Expected #{file_path} to exist"
        end

        it 'should have a markdown version' do
          file_path = "_site/licenses/#{spdx_lcase}/index.md"
          expect(File.exist?(file_path)).to be true, "Expected #{file_path} to exist"
        end

        it 'should have a JSON version' do
          file_path = "_site/licenses/#{spdx_lcase}/index.json"
          expect(File.exist?(file_path)).to be true, "Expected #{file_path} to exist"
        end
      end

      context 'JSON format content' do
        let(:json_path) { "_site/licenses/#{spdx_lcase}/index.json" }
        
        it 'should contain valid JSON' do
          skip "JSON file not generated yet" unless File.exist?(json_path)
          
          content = File.read(json_path)
          expect { JSON.parse(content) }.not_to raise_error
        end

        it 'should contain required fields' do
          skip "JSON file not generated yet" unless File.exist?(json_path)
          
          content = File.read(json_path)
          data = JSON.parse(content)
          
          expect(data).to have_key('title')
          expect(data).to have_key('spdx-id')
          expect(data).to have_key('description')
          expect(data).to have_key('body')
          expect(data).to have_key('permissions')
          expect(data).to have_key('conditions')
          expect(data).to have_key('limitations')
        end
      end
    end
  end
end
