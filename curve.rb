# reference: http://jeremykun.com/2013/05/11/bezier-curves-and-picasso/

require 'matrix'

class Curve
  def initialize p1, p2, p3, p4
    @curve = [p1, p2, p3, p4]
  end

  def self.draw_curve curve
    if is_flat? curve
      draw_segment curve
    else
      pieces = subdivide curve
      draw_curve pieces[0]
      draw_curve pieces[1]
    end
  end

  def self.draw_segment curve
    if curve.size == 4
      glVertex3f curve[0].[](0), curve[0].[](1) ,0
      glVertex3f curve[1].[](0), curve[1].[](1) ,0
      glVertex3f curve[1].[](0), curve[1].[](1) ,0
      glVertex3f curve[2].[](0), curve[2].[](1) ,0
      glVertex3f curve[2].[](0), curve[2].[](1) ,0
      glVertex3f curve[3].[](0), curve[3].[](1) ,0
    else
      glVertex3f curve[0].[](0), curve[0].[](1) ,0
      glVertex3f curve[1].[](0), curve[1].[](1) ,0
    end
  end

  private
  
  def self.is_flat? curve
    tol = 250
    a = 3.0 * curve[1] - 2.0 * curve[0] - curve[3]
    b = 3.0 * curve[2] - curve[0] - 2.0 * curve[3]
    ax = a.[](0) * a.[](0)
    ay = a.[](1) * a.[](1)
    bx = b.[](0) * b.[](0)
    by = b.[](1) * b.[](1)
    # p ([ax, bx].max + [ay, by].max)
    ([ax, bx].max + [ay, by].max) <= tol
  end
  
  def self.subdivide c
    first_midpoints = midpoints c 
    second_midpoints = midpoints first_midpoints 
    third_midpoints = midpoints second_midpoints 
 
    [[c[0], first_midpoints[0], second_midpoints[0], third_midpoints[0]],
     [third_midpoints[0], second_midpoints[1], first_midpoints[2], c[3]]]
  end
  
  def self.midpoints point_list
    midpoint = proc {|p, q|  (p + q) / 2 }
    final = []
    (point_list.size - 1).times do |i|
      final << (midpoint.call point_list[i], point_list[i+1])
    end
    final
  end
end
