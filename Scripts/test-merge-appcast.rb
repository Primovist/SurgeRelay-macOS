#!/usr/bin/env ruby
# frozen_string_literal: true

require "minitest/autorun"
require "open3"
require "tempfile"
require "rexml/document"

class MergeAppcastTest < Minitest::Test
  def test_keeps_new_signed_item_before_distinct_history
    new_feed = feed(item("202609101154", "new-signature"))
    old_feed = feed(item("202609091200", "old-signature"))

    Tempfile.create(["new", ".xml"]) do |new_file|
      Tempfile.create(["old", ".xml"]) do |old_file|
        Tempfile.create(["merged", ".xml"]) do |output|
          new_file.write(new_feed); new_file.flush
          old_file.write(old_feed); old_file.flush
          stdout, stderr, status = Open3.capture3(
            RbConfig.ruby, File.join(__dir__, "merge-appcast.rb"),
            new_file.path, old_file.path, output.path, "10"
          )
          assert status.success?, "#{stdout}\n#{stderr}"
          document = REXML::Document.new(File.read(output.path))
          items = document.elements["rss/channel"].get_elements("item")
          assert_equal %w[202609101154 202609091200], items.map { |entry|
            entry.elements["enclosure"].attributes.get_attribute("sparkle:version").value
          }
          assert_equal "new-signature",
                       items.first.elements["enclosure"].attributes.get_attribute("sparkle:edSignature").value
        end
      end
    end
  end

  private

  def feed(items)
    <<~XML
      <?xml version="1.0" encoding="utf-8"?>
      <rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle">
        <channel><title>Updates</title>#{items}</channel>
      </rss>
    XML
  end

  def item(version, signature)
    %(<item><title>#{version}</title><enclosure url="#{version}.zip" sparkle:version="#{version}" sparkle:shortVersionString="#{version}" sparkle:edSignature="#{signature}" /></item>)
  end
end
