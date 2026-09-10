#!/usr/bin/env ruby
# frozen_string_literal: true

require "rexml/document"
require "rexml/formatters/pretty"

abort "usage: merge-appcast.rb NEW OLD OUTPUT [MAX_ITEMS]" unless ARGV.length.between?(3, 4)

new_path, old_path, output_path = ARGV.take(3)
maximum_items = Integer(ARGV[3] || "10", 10)
new_document = REXML::Document.new(File.read(new_path))
old_document = File.exist?(old_path) ? REXML::Document.new(File.read(old_path)) : nil
new_channel = new_document.elements["rss/channel"] or abort "new appcast has no channel"
new_items = new_channel.get_elements("item")
abort "new appcast has no generated item" if new_items.empty?

new_versions = new_items.each_with_object({}) do |item, result|
  version = item.elements["enclosure"]&.attributes&.get_attribute("sparkle:version")&.value
  result[version] = true unless version.nil?
end

output_document = old_document || new_document
output_channel = output_document.elements["rss/channel"] || new_channel
output_channel.get_elements("item").each do |item|
  version = item.elements["enclosure"]&.attributes&.get_attribute("sparkle:version")&.value
  output_channel.delete_element(item) if version && new_versions.key?(version)
end
new_items.reverse_each do |item|
  first_item = output_channel.elements["item"]
  if first_item
    output_channel.insert_before(first_item, item.deep_clone)
  else
    output_channel.add_element(item.deep_clone)
  end
end
output_channel.get_elements("item").drop(maximum_items).each { |item| output_channel.delete_element(item) }
formatter = REXML::Formatters::Pretty.new(2)
formatter.compact = true
File.open(output_path, "w") do |file|
  file.write %(<?xml version="1.0" encoding="utf-8"?>\n)
  formatter.write(output_document.root, file)
  file.write "\n"
end
