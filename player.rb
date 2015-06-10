class Player
  attr_accessor :up, :down, :left, :right, :pos_x, :pos_y
  
  def initialize pos_x, pos_y, camera_rot_z, camera_rot_x
    @pos_x = pos_x
    @pos_y = pos_y
    @camera_rot_z = camera_rot_z
    @camera_rot_x = camera_rot_x
    @up = false
    @down = false
    @left = false
    @right = false
  end

  def move delta
    delta = delta * 40
    if @up and @down
    elsif @up
      @pos_x += Math.cos((@camera_rot_z / 360.0) * Math::PI * 2) * delta
      @pos_y += Math.sin((@camera_rot_z / 360.0) * Math::PI * 2) * delta
    elsif @down
      @pos_x -= Math.cos((@camera_rot_z / 360.0) * Math::PI * 2) * delta
      @pos_y -= Math.sin((@camera_rot_z / 360.0) * Math::PI * 2) * delta
    end
    if @left and @right
    elsif @left
      @pos_x -= Math.sin((@camera_rot_z / 360.0) * Math::PI * 2) * delta
      @pos_y += Math.cos((@camera_rot_z / 360.0) * Math::PI * 2) * delta
    elsif @right
      @pos_x += Math.sin((@camera_rot_z / 360.0) * Math::PI * 2) * delta
      @pos_y -= Math.cos((@camera_rot_z / 360.0) * Math::PI * 2) * delta
    end
  end
    
  def update_camera delta, mouse_x_mov, mouse_y_mov
    @camera_rot_z -= mouse_x_mov * delta * 5
    @camera_rot_x -= mouse_y_mov * delta * 5
    @camera_rot_x = 80 if @camera_rot_x > 80
    @camera_rot_x = -80 if @camera_rot_x < -80
  end
  def look_at
    [@pos_x, @pos_y, 20,
     @pos_x + Math.cos(@camera_rot_z * Math::PI / 180),
     @pos_y + Math.sin(@camera_rot_z * Math::PI / 180),
     Math.sin(@camera_rot_x * Math::PI / 180) + 20,
     0, 0, 1]
  end
end
