=begin
Copyright 2024, Author 
All Rights Reserved

License: AuthorsLicenseStatement 
Author: MSP
Organization:  
Name: ColorFolio
Version: 1.0.0
SU Version: SU2017 Up 
Date: 23 Oct 2024
Description: CoolerPalette, ColorRandomizer. 
Usage:  
History:
    1.0.0 2024-10-23 First Developed
=end

require 'sketchup.rb'
require 'extensions.rb'

module ColorFolio
  module_function

  def load_plugins
    # Load the ColorFolio main script which contains both functionalities
    require_relative 'ColorFolio/colorfolio_main'
  end

  # Register the main extension
  my_extension_loader = SketchupExtension.new('ColorFolio', 'msp_colorfolio.rb')
  my_extension_loader.copyright = 'Copyright 2024 by MSP'
  my_extension_loader.creator = 'MSP'
  my_extension_loader.version = '1.0.0'
  my_extension_loader.description = 'A plugin for applying random colors and coolors palettes to selected objects.'

  Sketchup.register_extension(my_extension_loader, true)
end

# Call the load_plugins method to initialize the plugin
ColorFolio.load_plugins