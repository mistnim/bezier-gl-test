#!/usr/bin/env ruby
# coding: utf-8
require_relative 'svg'
require_relative 'player'

require 'opengl'
require 'glu'
require 'glut'

require 'color'
# require 'mathn'

# Add GL and GLUT namespaces in to make porting easier
include Gl
include Glu
include Glut

# Placeholder for the window object
WIDTH = 800
HEIGHT = 600

AREA = 700 #for the forest

BLACK = Color::RGB::Black
WHITE = Color::RGB::White
SPECULAR_AND_DIFFUSE = WHITE
AMBIENT = Color::RGB.new(90,90,90)

class Lesson3
  def init_gl_window width = 640, height = 480
    # Background color to black
    glClearColor *BLACK.to_a, 1
    # Enables clearing of depth buffer
    glClearDepth 1.0
    # Set type of depth test
    glDepthFunc GL_LEQUAL
    # Enable depth testing
    glEnable GL_DEPTH_TEST
    # Enable smooth color shading
    glShadeModel GL_SMOOTH

    glColorMaterial GL_FRONT, GL_AMBIENT_AND_DIFFUSE
    glEnable GL_COLOR_MATERIAL

    glLightfv GL_LIGHT0, GL_DIFFUSE, SPECULAR_AND_DIFFUSE.to_a + [1]
    glLightfv GL_LIGHT0, GL_SPECULAR,SPECULAR_AND_DIFFUSE.to_a + [1]
    glLightfv GL_LIGHT0, GL_AMBIENT, AMBIENT.to_a + [1]

    # Set global ambient light color
    glLightModelfv GL_LIGHT_MODEL_AMBIENT, BLACK.to_a

    # Set specular for all the objects
    #glMaterialfv GL_FRONT, GL_SPECULAR, WHITE.to_a
    #glMaterialf(GL_FRONT, GL_SHININESS , 128);
    
    glEnable GL_LIGHTING
    glEnable GL_LIGHT0

    glMatrixMode GL_MODELVIEW
    
    glFogi(GL_FOG_MODE, GL_LINEAR);        # Fog Mode
    glFogfv(GL_FOG_COLOR, [*BLACK.to_a, 1]);            # Set Fog Color
    glFogf(GL_FOG_DENSITY, 0.35);              # How Dense Will The Fog Be
    glHint(GL_FOG_HINT, GL_DONT_CARE);          # Fog Hint Value
    glFogf(GL_FOG_START, 100.0);             # Fog Start Depth
    glFogf(GL_FOG_END, 500.0);               # Fog End Depth
    glEnable(GL_FOG);                   # Enables GL_FOG

    draw_gl_scene
  end

  def reshape width, height
    height = 1 if height == 0

    # Reset current viewpoint and perspective transformation
    glViewport 0, 0, width, height

    glMatrixMode GL_PROJECTION
    glLoadIdentity

    gluPerspective 45.0, width.to_f / height, 0.1, 1000.0
    glMatrixMode GL_MODELVIEW
  end

  def initialize_rubies
    @rubies = Array.new
    @score.times do
      @rubies << [rand(AREA), rand(AREA)]
    end
  end

  def draw_rubies
    @rubies.each do |i|
      glPushMatrix do
        glTranslatef i[0], i[1], 10
        glRotatef -90, 1, 0, 0
        glScalef 0.05, 0.05, 0.05
        glRotatef 36, 0,1,0
        @ruby.draw 
      end
    end
  end

  def check_rubies
    @rubies.map! do |i|
      if (@player.pos_x - i[0]).abs < 30 and (@player.pos_y - i[1]).abs < 30
        @score-= 1
        ret = nil
      else
        ret = i
      end
    end
    @rubies.delete nil
  end
    
  def initialize_forest
    @forest = Array.new
    bad_tries = 0
    loop do
      break if bad_tries > 3
      too_close = false
      try = [rand(AREA), rand(AREA)]
      @forest.each do |i|
        if (try[0] - i[0]).abs < 70 and (try[1] - i[1]).abs < 70
          too_close = true
        end
      end
      if too_close
        bad_tries += 1
      else
        @forest << [try[0], try[1], rand(2)]
        bad_tries = 0
      end
    end
  end

  def draw_forest
    @forest.each do |i|
      if i[2] == 0
        tree = @tree1
      else
        tree = @tree2
      end
      glPushMatrix do
        glTranslatef i[0], i[1], 0
        glRotatef -90, 1, 0, 0
        glScalef 0.1, 0.1, 0.1
        10.times do
          glRotatef 36, 0,1,0
          tree.draw 
        end
      end
    end
  end
  
  def rect x1, y1, x2, y2, t_id
    glBegin GL_QUADS do
      glNormal3f 0, 0, 1
      glVertex3f x1, y1, 0.0
      glVertex3f x2, y1, 0.0
      glVertex3f x2, y2, 0.0
      glVertex3f x1, y2, 0.0
    end
  end

  def draw_floor
    rect -20, -20, 20, 20, 0
  end
  
  def draw_gl_scene
    new_time = Time.now
    delta = @old_time ? (new_time - @old_time) : 0
    @old_time = new_time


    mouse_x_mov = 0             # camera updated, movements is now zero
    mouse_y_mov = 0
    @player.move delta
    @player.update_camera delta, @mouse_x_mov, @mouse_y_mov
    glClear GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT

    glPushMatrix do

      gluLookAt *@player.look_at
      #sglTranslatef 0,0,-20
      glLightfv GL_LIGHT0, GL_POSITION, [2, -2, 2, 0]
      
      glColor3f *@c.to_a
      glPushMatrix do
        glTranslatef 10000,-4,0
        glutSolidSphere 1, 20,20
      end
      check_rubies
      draw_forest
      draw_rubies

    end

    # display the HUD
    glMatrixMode(GL_PROJECTION);
    glPushMatrix();
    glDisable(GL_LIGHTING)
    glLoadIdentity();
    glOrtho(0.0, WIDTH, HEIGHT, 0.0, -1.0, 10.0);
    glMatrixMode(GL_MODELVIEW);

    glLoadIdentity();

    glClear(GL_DEPTH_BUFFER_BIT);

    @score.times do |i|
      glPushMatrix do
        glTranslatef 5 + i*70, 5, 0
        glScalef 0.3, 0.3, 0.3
        @ruby.draw
      end
    end

    # Making sure we can render 3d again
    glEnable(GL_LIGHTING)
    glMatrixMode(GL_PROJECTION);
    glPopMatrix();
    glMatrixMode(GL_MODELVIEW);
    # Swap buers or display
    glutSwapBuffers
  end

  # The idle function to handle
  def idle
    glutPostRedisplay
  end

  # Keyboard handler to exit when ESC is typed
  def keyboard key, x, y
    case key
    when 'e'
      @player.up = true
    when 'd'
      @player.down = true
    when 'f'
      @player.right = true
    when 's'
      @player.left = true
    when 'q'
      glutDestroyWindow @window
      exit(0)
    end
    glutPostRedisplay
  end

  def keyboard_up key, x, y
    case key
    when 'e'
      @player.up = false
    when 'd'
      @player.down = false
    when 'f'
      @player.right = false
    when 's'
      @player.left = false
    end
  end

  def mouse_passive_motion x, y
    @mouse_x_mov = x - WIDTH / 2
    @mouse_y_mov = y - HEIGHT / 2
    glutWarpPointer WIDTH / 2, HEIGHT / 2 unless x == (WIDTH / 2) and y == (HEIGHT / 2)
  end

  def initialize
    @score = 5
    @mouse_x_mov = 0.0
    @mouse_y_mov = 0.0
    
    @window = nil
    @c = Color::RGB::Yellow
    @player = Player.new -100, -100, 45, 0
    a = Vector.[] 0.0, 0.0
    b = Vector.[] 2.0, 10.0
    c = Vector.[] 4.0, 10.0
    d = Vector.[] 6.0, 0.0
    
    cc = [a,b,c,d]
    @curve = Curve.new *cc
    
    # Initliaze our GLUT code
    glutInit
    # Setup a double buffer, RGBA color, alpha components and depth buffer
    glutInitDisplayMode GLUT_RGB | GLUT_DOUBLE | GLUT_DEPTH | GLUT_ALPHA
    glutInitWindowSize WIDTH, HEIGHT
    glutInitWindowPosition 0, 0
    @window = glutCreateWindow "float"
    glutIdleFunc :idle
    glutDisplayFunc :draw_gl_scene
    glutReshapeFunc :reshape
    glutKeyboardFunc :keyboard
    glutKeyboardUpFunc :keyboard_up
    glutPassiveMotionFunc :mouse_passive_motion
    glutIgnoreKeyRepeat 1
    glutSetCursor GLUT_CURSOR_NONE
    @index = glGenLists 3
    @ruby = SVG.new 'images/ruby.svg', @index
    @tree1 = SVG.new 'images/tree1.svg', @index + 1
    @tree2 = SVG.new 'images/tree2.svg', @index + 2
    initialize_forest
    initialize_rubies
    init_gl_window WIDTH, HEIGHT
    glutMainLoop
  end
end

Lesson3.new
