require "net/https"
require "xmlsimple"

module Bisu
  class KnowledgeBase
    def initialize(sheet_id, keys_column_title)
      @sheet_id = sheet_id
      @key      = keys_column_title
    end

    def has_language?(language)
      kb[:languages].include?(language)
    end

    def localize(key, language)
      (locals = kb[:keys][key]) && (res = locals[language]) ? res : nil
    end

    private

    def kb
      @@kb ||= parse(raw_data(@sheet_id), @key)
    end

    def feed_data(uri, headers=nil)
      uri = URI.parse(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      data = http.get(uri.path, headers)
      XmlSimple.xml_in(data.body, 'KeyAttr' => 'name')
    end

    def raw_data(sheet_id)
      Logger.info("Downloading Knowledge Base...")
      sheet = feed_data("https://spreadsheets.google.com/feeds/worksheets/#{sheet_id}/public/full")
      feed_data(sheet["entry"][0]["link"][0]["href"])
    end

    def parse(raw_data, key)
      Logger.info("Parsing Knowledge Base...")

      remove = ["id", "updated", "category", "title", "content", "link", key]

      kb_keys = {}
      raw_data["entry"].each do |entry|
        hash = entry.select { |d| !remove.include?(d) }
        hash = hash.each.map { |k, v| v.first == {} ? [k, nil] : [k, v.first] }
        kb_keys[entry[key].first] = Hash[hash]
      end

      kb = { languages: kb_keys.values.first.keys, keys: kb_keys }

      Logger.info("Knowledge Base parsed successfully!")
      Logger.info("Found #{kb[:keys].count} keys in #{kb[:languages].count} languages.")

      kb
    end
  end
end
