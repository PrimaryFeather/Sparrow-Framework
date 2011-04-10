#!/usr/bin/env ruby

#
#  hiero2sparrow.rb
#  Sparrow
#
#  Created by Daniel Sperl on 11.02.2010
#  Copyright 2010 Incognitek. All rights reserved.
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the Simplified BSD License.
#

#  This script converts Bitmap Font files created with the "Hiero"-Tool to the 
#  format that is expected by Sparrow. See README for more information.

require "rexml/document"

SPACE_MARKER = '#SPACE#'

if $*.count == 0
  puts "Usage: hiero2sparrow.rb input.fnt [output.fnt]"
  exit
end

# get commandline-arguments
input_file_path = $*[0]
output_file_path = $*.count >= 2 ? $*[1] : input_file_path

if !File.exist?(input_file_path)
  puts "File #{input_file_path} not found!"
  exit
end

xml_doc = REXML::Document.new
xml_doc << REXML::XMLDecl.new

root_element = xml_doc.add_element "font"
current_parent = root_element
pages_parent = nil
chars_parent = nil
kernings_parent = nil
num_chars = 0
num_kernings = 0

puts "Parsing #{input_file_path} ..."

IO.foreach(input_file_path) do |line|    
  
  # replace spaces within quotes
  line.gsub!(/"(\S*)(\s+)(\S*")/) { |match| $1 + SPACE_MARKER + $3 }  

  line_parts = line.split /\s+/    
  element_name = line_parts.shift  

  next if element_name == "chars" || element_name == "kernings"
  
  if element_name == "page"
    pages_parent ||= root_element.add_element "pages"
    current_parent = pages_parent
  elsif element_name == "char"
    chars_parent ||= root_element.add_element "chars"
    current_parent = chars_parent
    num_chars += 1
  elsif element_name == "kerning"
    kernings_parent ||= root_element.add_element "kernings"
    current_parent = kernings_parent
    num_kernings += 1
  end
  
  current_element = current_parent.add_element element_name
  
  line_parts.each do |part|
    name, value = part.split("=")
    current_element.attributes[name] = value.gsub('"', "").gsub(SPACE_MARKER, " ")
  end
    
end

chars_parent.attributes["count"] = num_chars
kernings_parent.attributes["count"] = num_kernings unless kernings_parent.nil?

puts "Saving output to #{output_file_path} ..."

File.open output_file_path, 'w+' do |file|
  xml_doc.write file, 2
end

puts "Finished successfully."
