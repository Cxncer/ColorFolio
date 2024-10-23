require 'sketchup.rb'

module ColorFolio
  # Method to convert a hex color code to Sketchup::Color
  def self.hex_to_color(hex)
    hex = hex.gsub('#', '')  # Remove hash if present
    r = hex[0..1].to_i(16)
    g = hex[2..3].to_i(16)
    b = hex[4..5].to_i(16)
    Sketchup::Color.new(r, g, b)
  end

  # Method to extract color codes from a Coolors URL
  def self.extract_colors_from_url(url)
    if url =~ /coolors\.co\/(?:palette\/)?([a-fA-F0-9-]+)/ # Match color palette codes in the URL
      color_codes = $1.split('-')  # Extract and split the hex color codes
      color_codes.map { |hex| hex_to_color(hex) }  # Convert hex to Sketchup::Color objects
    else
      UI.messagebox('Invalid Coolors.co URL. Please provide a valid palette URL.')
      []
    end
  end

  # Method to apply the colors to the selected objects
  def self.apply_colors(colors)
    model = Sketchup.active_model
    selection = model.selection

    if selection.empty?
      UI.messagebox('Please select one or more objects to apply colors.')
      return
    end

    shuffled_colors = colors.shuffle
    color_count = shuffled_colors.length

    puts "Shuffled Colors: #{shuffled_colors.map(&:to_s)}" # Debug message

    selection.each_with_index do |entity, index|
      next unless entity.is_a?(Sketchup::Group) || entity.is_a?(Sketchup::ComponentInstance) || entity.is_a?(Sketchup::Face)

      if index < color_count
        color = shuffled_colors[index]
      else
        UI.messagebox('Not enough colors in the palette for the selected objects.')
        break
      end

      material_name = "PaletteMaterial_#{rand(1000)}_#{index}"  # Ensure unique material names
      material = model.materials.add(material_name)
      material.color = color
      entity.material = material

      puts "Assigned color #{color.to_s} to entity #{entity} with material #{material_name}" # Debug message
    end

    UI.messagebox("Colors applied to selected objects!")
  end

  # Method to apply random colors to selected objects
  def self.apply_random_colors
    model = Sketchup.active_model
    selection = model.selection

    if selection.empty?
      UI.messagebox('Please select one or more objects to ColorRandomizer.')
      return
    end

    selection.each do |entity|
      next unless entity.is_a?(Sketchup::Group) || entity.is_a?(Sketchup::ComponentInstance) || entity.is_a?(Sketchup::Face)

      material = entity.material || model.materials.add("RandomMaterial_#{rand(1000)}")
      material.color = Sketchup::Color.new(rand(255), rand(255), rand(255))
      entity.material = material
    end

    UI.messagebox('Random colors applied to selected objects!')
  end

  # Method to prompt user for a Coolors.co URL and apply the palette
  def self.prompt_and_apply_colors
    prompts = ['Enter Coolors.co palette URL:']
    defaults = ['https://coolors.co/palette/264653-2a9d8f-e9c46a-f4a261-e76f51']
    input = UI.inputbox(prompts, defaults, 'Coolors.co Palette URL')

    return if input.nil? || input[0].strip.empty?

    colors = extract_colors_from_url(input[0].strip)
    apply_colors(colors) unless colors.empty?
  end
end

unless file_loaded?(File.basename(__FILE__))
  # Add menu items to activate the sub-functions
  UI.menu('Plugins').add_item('Apply Cooler Palette') {
    ColorFolio.prompt_and_apply_colors
  }

  UI.menu('Plugins').add_item('Apply Random Colors') {
    ColorFolio.apply_random_colors
  }

  # Add a toolbar with icons for both functions
  toolbar = UI::Toolbar.new 'ColorFolio'

  cmd_cooler_palette = UI::Command.new('Apply Cooler Palette') {
    ColorFolio.prompt_and_apply_colors
  }
  cmd_cooler_palette.tooltip = 'Apply color palette from Coolors.co'
  cmd_cooler_palette.menu_text = 'Apply Cooler Palette'
  cmd_cooler_palette.small_icon = File.join(File.dirname(__FILE__), 'icons', 'cooler_palette.png')
  cmd_cooler_palette.large_icon = File.join(File.dirname(__FILE__), 'icons', 'cooler_palette.png')

  cmd_random_color = UI::Command.new('Apply Random Colors') {
    ColorFolio.apply_random_colors
  }
  cmd_random_color.tooltip = 'Apply random colors to selected objects'
  cmd_random_color.menu_text = 'Apply Random Colors'
  cmd_random_color.small_icon = File.join(File.dirname(__FILE__), 'icons', 'color_randomizer.png')
  cmd_random_color.large_icon = File.join(File.dirname(__FILE__), 'icons', 'color_randomizer.png')

  toolbar.add_item cmd_cooler_palette
  toolbar.add_item cmd_random_color
  toolbar.show

  file_loaded(File.basename(__FILE__))
end
