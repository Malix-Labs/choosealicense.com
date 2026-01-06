# frozen_string_literal: true

require 'json'

module Jekyll
  class LicenseFormatsGenerator < Generator
    safe true
    priority :low

    def generate(site)
      return unless site.collections.key?('licenses')

      licenses = site.collections['licenses'].docs

      licenses.each do |license|
        # Add spdx-lcase to license data
        spdx_lcase = File.basename(license.basename, '.txt')
        license.data['spdx-lcase'] = spdx_lcase
        
        # Generate markdown version
        generate_markdown_page(site, license)
        
        # Generate JSON version
        generate_json_page(site, license)
        
        # Generate plain text version (raw text without YAML front matter)
        generate_plaintext_page(site, license)
      end
    end

    private

    def generate_markdown_page(site, license)
      markdown_page = LicenseFormatPage.new(site, license, 'md')
      site.pages << markdown_page
    end

    def generate_json_page(site, license)
      json_page = LicenseJsonPage.new(site, license)
      site.pages << json_page
    end

    def generate_plaintext_page(site, license)
      plaintext_page = LicensePlainTextPage.new(site, license)
      site.pages << plaintext_page
    end
  end

  class LicenseFormatPage < Page
    def initialize(site, license, format)
      @site = site
      @base = site.source
      @dir = File.join('licenses', license.data['spdx-lcase'])
      @name = "index.#{format}"

      self.process(@name)
      self.read_yaml(File.join(@base, '_layouts'), 'license-format.md')
      
      # Copy all license data
      self.data.merge!(license.data)
      self.data['layout'] = 'none'
      self.content = license.content
    end
  end

  class LicenseJsonPage < Page
    def initialize(site, license)
      @site = site
      @base = site.source
      @dir = File.join('licenses', license.data['spdx-lcase'])
      @name = 'index.json'

      self.process(@name)
      
      # Create JSON structure
      json_data = {
        'title' => license.data['title'],
        'spdx-id' => license.data['spdx-id'],
        'description' => license.data['description'],
        'how' => license.data['how'],
        'permissions' => license.data['permissions'],
        'conditions' => license.data['conditions'],
        'limitations' => license.data['limitations'],
        'body' => license.content
      }
      
      # Add optional fields if present
      json_data['nickname'] = license.data['nickname'] if license.data['nickname']
      json_data['note'] = license.data['note'] if license.data['note']
      json_data['using'] = license.data['using'] if license.data['using']
      json_data['featured'] = license.data['featured'] if license.data['featured']
      json_data['hidden'] = license.data['hidden'] if license.data['hidden']
      
      self.content = JSON.pretty_generate(json_data)
      self.data = { 'layout' => 'none' }
    end
    
    def output
      self.content
    end
  end

  class LicensePlainTextPage < Page
    def initialize(site, license)
      @site = site
      @base = site.source
      @dir = File.join('licenses', license.data['spdx-lcase'])
      @name = 'index.txt'

      self.process(@name)
      
      # Just the plain license text
      self.content = license.content
      self.data = { 'layout' => 'none' }
    end
    
    def output
      self.content
    end
  end
end
