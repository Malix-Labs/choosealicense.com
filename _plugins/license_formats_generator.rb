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
        # Add spdx-lcase to license data (derived from spdx-id)
        spdx_lcase = license.data['spdx-id'].downcase
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
      markdown_page = LicenseMarkdownPage.new(site, license)
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

  class LicenseMarkdownPage < Page
    def initialize(site, license)
      @site = site
      @base = site.source
      @dir = File.join('licenses', license.data['spdx-lcase'])
      @name = 'index.md'

      self.process(@name)
      self.data = {}
      
      # Build markdown content
      self.content = build_markdown_content(license)
    end
    
    private
    
    def build_markdown_content(license)
      content = "# #{license.data['title']}\n\n"
      
      if license.data['nickname']
        content += "**#{license.data['nickname']}**\n\n"
      end
      
      content += "#{license.data['description']}\n\n"
      content += "## License Text\n\n"
      content += "```\n#{license.content}```\n\n"
      
      content += "## Permissions\n\n"
      license.data['permissions'].each do |permission|
        content += "- #{permission}\n"
      end
      content += "\n"
      
      content += "## Conditions\n\n"
      license.data['conditions'].each do |condition|
        content += "- #{condition}\n"
      end
      content += "\n"
      
      content += "## Limitations\n\n"
      license.data['limitations'].each do |limitation|
        content += "- #{limitation}\n"
      end
      content += "\n"
      
      if license.data['how']
        content += "## How to Apply\n\n"
        content += "#{license.data['how']}\n"
      end
      
      content
    end
    
    def output
      self.content
    end
  end

  class LicenseJsonPage < Page
    def initialize(site, license)
      @site = site
      @base = site.source
      @dir = File.join('licenses', license.data['spdx-lcase'])
      @name = 'index.json'

      self.process(@name)
      self.data = {}
      
      # Create JSON structure
      json_data = {
        'title' => license.data['title'],
        'spdx-id' => license.data['spdx-id'],
        'description' => license.data['description'],
        'permissions' => license.data['permissions'],
        'conditions' => license.data['conditions'],
        'limitations' => license.data['limitations'],
        'body' => license.content
      }
      
      # Add optional fields if present
      json_data['how'] = license.data['how'] if license.data['how']
      json_data['nickname'] = license.data['nickname'] if license.data['nickname']
      json_data['note'] = license.data['note'] if license.data['note']
      json_data['using'] = license.data['using'] if license.data['using']
      json_data['featured'] = license.data['featured'] if license.data.key?('featured')
      json_data['hidden'] = license.data['hidden'] if license.data.key?('hidden')
      
      self.content = JSON.pretty_generate(json_data)
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
      self.data = {}
      
      # Just the plain license text
      self.content = license.content
    end
    
    def output
      self.content
    end
  end
end
