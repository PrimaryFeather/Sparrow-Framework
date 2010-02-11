#!/usr/bin/env ruby

#
#  packer2sparrow.rb
#  Sparrow
#
#  Created by Daniel Sperl on 11.02.2010
#  Copyright 2010 Incognitek. All rights reserved.
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the Simplified BSD License.
#

#  This script converts atlas XML files created with the "Packer"-Tool to the 
#  format that is expected by Sparrow. See README for more information.

if $*.count < 2
  puts "Usage: packer2sparrow.rb input.xml image.png [output.xml]"
  exit
end

# get commandline-arguments
input_file_path = $*[0]
image_file_path = $*[1]
output_file_path = $*.count >= 3 ? $*[2] : input_file_path

if !File.exist?(input_file_path)
  puts "File #{input_file_path} not found!"
  exit
end

puts "Parsing #{input_file_path} ..."

contents = IO.read input_file_path
  
contents.gsub! "<sheet>", "<TextureAtlas imagePath='#{image_file_path}'>"
contents.gsub! "<sprite ", "<SubTexture "
contents.gsub! /.png"/, '"'
contents.gsub! "</sheet>", "</TextureAtlas>"

puts "Saving output to #{output_file_path} ..."

File.open output_file_path, 'w+' do |file|
  file << contents
end

puts "Finished successfully."
