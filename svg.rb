require_relative 'subpath'

require 'savage'
require 'nokogiri'
require 'pry'
class SVG
  def initialize file_name, index
    @index = index
    paths = parse_svg file_name
    glNewList(@index, GL_COMPILE)
    draw_paths paths
    glEndList
  end

  def draw
    glCallList @index
  end
  
  private
  
  def draw_paths paths
    paths.each do |path|
      SubPath.draw path[0], path[1]
    end
  end

  def parse_svg file_name
    paths = []
    svg = Nokogiri::XML(open(file_name))
    svg.css('path').each do |path|
      style = path['style']
      index = style.index('stroke:') + 'stroke:'.size
      color_hex = style[index..index+6]
      color = Color::RGB.from_html(color_hex)
      paths << [(parse_path path['d']), color]
    end
    paths
  end
  
  def parse_path path_string
    curves = []
    offset = nil
    last_point = nil
    path_data = Savage::Parser.parse path_string
    path_data.subpaths.first.directions.each do |direction|
      case direction
      when Savage::Directions::MoveTo
        move_to = direction.to_a.map {|a| a.to_f}
        offset = Vector.[] *move_to[1..2]
        last_point = offset
      when Savage::Directions::LineTo
        line_to =  Vector.[] *(direction.to_a[1..2].map {|a| a.to_f})
        line_to = line_to + last_point unless direction.absolute?
        curves << [last_point, line_to]
        last_point = line_to
      when Savage::Directions::CubicCurveTo
        cubic = direction.to_a.map {|a| a.to_f}
        curve = [last_point]
        new_points = cubic[1..-1].each_slice(2).to_a.map {|slice| Vector.[] *slice}
        new_points.map! {|point| point + last_point} unless direction.absolute?
        curve.concat new_points
        last_point = curve.last
        curves << curve
      end
    end
    curves
  end
end

