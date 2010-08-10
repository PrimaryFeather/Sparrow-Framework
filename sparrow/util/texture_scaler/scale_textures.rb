#!/usr/bin/env ruby

#
#  scale_textures.rb
#  Sparrow
#
#  Created by Daniel Sperl on 09.07.2010
#  Copyright 2010 Incognitek. All rights reserved.
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the Simplified BSD License.
#

require 'rubygems'
require 'ftools'
require 'quick_magick'
require 'optparse'
require 'ostruct'

include QuickMagick

# --------------------------------------------------------------------------------------------------
# --- option parsing -------------------------------------------------------------------------------
# --------------------------------------------------------------------------------------------------

options = OpenStruct.new
options.sharpen = false
options.scale = 0.5
options.purge_suffix = "@2x"
options.append_suffix = ""

option_parser = OptionParser.new do |opts|

  opts.banner = "Usage: #{File.basename(__FILE__)} [options] source_images target_path"
 
  opts.separator ""
  opts.separator "Options:" 
 
  opts.on('-s', '--scale FACTOR', Float, 'Scale textures (default: 0.5)') do |factor|
    options.scale = factor
  end
 
  opts.on('-r', '--sharpen', 'Sharpen images') do
    options.sharpen = true
  end
  
  opts.on('-p', '--purge_suffix SUFFIX', 'Remove suffix on copies (default: @2x)') do |suffix|
    options.purge_suffix = suffix
  end
  
  opts.on("-a", "--append_suffix SUFFIX", "Add suffix to copies") do |suffix|
    options.append_suffix = suffix
  end
 
  opts.on_tail('-h', '--help', 'Show this message') do
    puts opts
    exit
  end
 
end

if (ARGV.length < 2)
  puts option_parser
  exit
else
  option_parser.parse!
end

# --------------------------------------------------------------------------------------------------
# --- image processing -----------------------------------------------------------------------------
# --------------------------------------------------------------------------------------------------

source_files = ARGV.clone
target_path = source_files.pop

images = source_files.collect { |file| Image.read(file).first }

if images.count == 0
  puts "No images found!"
  exit
else
  File.makedirs target_path
end

images.each do |image|
  extname = File.extname(image.image_filename)
  basename = File.basename(image.image_filename, extname)
  basename.gsub!(options.purge_suffix, "") if basename.end_with? options.purge_suffix
  fullpath = File.join(target_path, basename + options.append_suffix + extname)
  
  image.resize "#{options.scale * 100}%"
  image.append_to_operators 'filter', 'Box' if (options.scale == 0.5 || options.scale == 0.25)  
  image.append_to_operators 'sharpen', 1    if (options.sharpen)
  image.save fullpath
  puts "Saved #{fullpath}"
end
