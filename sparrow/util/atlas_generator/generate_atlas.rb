#!/usr/bin/env ruby

#
#  generate_atlas.rb
#  Sparrow
#
#  Created by Daniel Sperl on 14.06.2010
#  Copyright 2010 Incognitek. All rights reserved.
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the Simplified BSD License.
#

require 'rubygems'
require 'fileutils'
require 'quick_magick'
require 'optparse'
require 'ostruct'
require 'rexml/document'

include REXML
include QuickMagick

# --------------------------------------------------------------------------------------------------
# --- worker classes -------------------------------------------------------------------------------
# --------------------------------------------------------------------------------------------------

class TextureNode
  attr_accessor :image
  attr_reader :rect
  
  def initialize(x, y, width, height)
    @rect = Rectangle.new(x, y, width, height)
  end  
  
  def insert_image(image, scale, padding)
    if @image.nil?
      img_width = (image.width * scale.to_f + padding).to_i
      img_height = (image.height * scale.to_f + padding).to_i
      if (img_width <= @rect.width and img_height <= @rect.height)
        @image = image
        @children = []
        rest_width = @rect.width - img_width
        rest_height = @rect.height - img_height        
        if (rest_width > rest_height)
          @children << TextureNode.new(@rect.x, @rect.y + img_height, 
                                       img_width, @rect.height - img_height)
          @children << TextureNode.new(@rect.x + img_width, @rect.y,
                                       @rect.width - img_width, @rect.height)
        else
          @children << TextureNode.new(@rect.x + img_width, @rect.y,
                                       @rect.width - img_width, img_height)
          @children << TextureNode.new(@rect.x, @rect.y + img_height,
                                       @rect.width, @rect.height - img_height)
        end
        return self
      else
        return nil
      end
    else
      new_node = @children[0].insert_image(image, scale, padding)
      unless (new_node.nil?)
        return new_node
      else
        return @children[1].insert_image(image, scale, padding)
      end
    end    
  end
  
  def image_name
    image.nil? ? nil : File.basename(image.image_filename, File.extname(image.image_filename))
  end
  
end

class Rectangle
  attr_reader :x, :y, :width, :height  
  def initialize(x, y, width, height)
    @x = x
    @y = y
    @width = width
    @height = height    
  end
end

# --------------------------------------------------------------------------------------------------
# --- option parsing -------------------------------------------------------------------------------
# --------------------------------------------------------------------------------------------------

options = OpenStruct.new
options.scale = 1
options.padding = 1
options.sharpen = false
options.maxsize = [1024, 1024]
options.verbose = true
 
option_parser = OptionParser.new do |opts|

  opts.banner = "Usage: #{File.basename(__FILE__)} [options] source_images target_file"
 
  opts.separator ""
  opts.separator "Options:" 
 
  opts.on('-s', '--scale FACTOR', Float, 'Scale textures') do |factor|
    options.scale = factor
  end
 
  opts.on('-p', '--padding DISTANCE', Integer, 'Padding of subtextures (default: 1)') do |distance|
    options.padding = distance
  end
 
  opts.on('-r', '--sharpen', 'Sharpen images') do
    options.sharpen = true
  end
  
  opts.on('-m', '--maxsize WIDTHxHEIGHT', 'Maximum atlas size (default: 1024x1024)') do |size|
    options.maxsize = size.split('x').collect { |v| v.to_i }    
  end
  
  opts.on("-v", "--[no-]verbose", "Run verbosely (default: verbose)") do |verbose|
    options.verbose = verbose
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

@verbose = options.verbose
def vputs(text)
  puts text if @verbose
end

# --------------------------------------------------------------------------------------------------
# --- image processing -----------------------------------------------------------------------------
# --------------------------------------------------------------------------------------------------

# get commandline-arguments
source_files = ARGV.clone
target_file = source_files.pop

if source_files.count == 0
  puts "No images found!"
  exit
end

images = source_files.collect { |file| Image.read(file).first }
images.sort! { |i, j| (j.width * j.height) <=> (i.width * i.height) }

vputs "Found #{images.count} images."

# Start with a small atlas and make it bigger until all textures fit.

image_nodes = []
current_width, current_height = 32, 32
loop_count = 0
textures_fit = false

until textures_fit do
  textures_fit = true
  root_node = TextureNode.new(0, 0, current_width + options.padding, current_height + options.padding)
  image_nodes = []

  images.each do |image|
    new_node = root_node.insert_image(image, options.scale, options.padding)
    if new_node.nil? then
      textures_fit = false
      break
    else
      image_nodes << new_node
    end
  end
  
  unless textures_fit
    loop_count += 1
    if loop_count % 3 < 2
      current_width *= 2
    else
      current_width /= 2
      current_height *= 2
    end
  end
end

if current_width > options.maxsize[0] or current_height > options.maxsize[1]
  puts "Error: Textures did not fit into a #{options.maxsize[0]}x#{options.maxsize[1]} image"
  exit
else
  vputs "Arranged images in #{current_width}x#{current_height} atlas."
end

vputs "Drawing atlas ..."

atlas_image = Image::solid(current_width, current_height, :transparent)

# Use box filter for downscaling by whole number (creates sharper output)
atlas_image.append_to_operators 'filter', 'Box' if (options.scale == 0.5 || options.scale == 0.25)

# Draw all images into atlas
image_nodes.each do |node|
  atlas_image.draw_image :over, node.rect.x, node.rect.y, 
                                (node.image.width * options.scale).to_i, 
                                (node.image.height * options.scale).to_i, 
                                "{" + node.image.image_filename + "}"
end

# Apply sharpening filter if requested
atlas_image.append_to_operators 'sharpen', 1 if (options.sharpen)

# Save output to correct path
target_path = File.dirname(target_file)
FileUtils.makedirs target_path
atlas_name  = File.basename(target_file, File.extname(target_file))
atlas_image_path = File.join(target_path, atlas_name) + ".png" 
atlas_image.save(atlas_image_path)

puts "Saved #{atlas_image_path}"

# --------------------------------------------------------------------------------------------------
# --- XML creation ---------------------------------------------------------------------------------
# --------------------------------------------------------------------------------------------------

atlas_xml_path = File.join(target_path, atlas_name) + ".xml"

xml_doc = Document.new
xml_doc << XMLDecl.default
root = Element.new "TextureAtlas"
root.attributes["imagePath"] = atlas_name + ".png"

image_nodes.each do |node|
  subnode = Element.new "SubTexture"
  subnode.attributes["name"] = File.basename(node.image_name)
  subnode.attributes["x"] = node.rect.x
  subnode.attributes["y"] = node.rect.y
  subnode.attributes["width"] = node.image.width * options.scale.to_f
  subnode.attributes["height"] = node.image.height * options.scale.to_f
  root << subnode
end

xml_doc << root

File.open(atlas_xml_path, "w") do |file|
  xml_doc.write file, 2
end

puts "Saved #{atlas_xml_path}"
