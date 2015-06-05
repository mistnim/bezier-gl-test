require_relative 'curve'

class SubPath
  def self.draw curves
    glLineWidth 2
    glBegin GL_LINES do
      curves.each do |c|
        if c.size == 4
          Curve.draw_curve c
        else
          Curve.draw_segment c
        end
      end
    end
  end
end
