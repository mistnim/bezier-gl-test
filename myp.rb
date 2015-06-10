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

BLACK = Color::RGB::Black
WHITE = Color::RGB::White
SPECULAR_AND_DIFFUSE = WHITE
AMBIENT = Color::RGB.new(20,20,20)

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

    glMatrixMode GL_PROJECTION
    glLoadIdentity
    # Calculate aspect ratio of the window
    gluPerspective 45.0, width / height, 0.1, 100.0

    glMatrixMode GL_MODELVIEW

    draw_gl_scene
  end

  def reshape width, height
    height = 1 if height == 0

    # Reset current viewpoint and perspective transformation
    glViewport 0, 0, width, height

    glMatrixMode GL_PROJECTION
    glLoadIdentity

    gluPerspective 45.0, width.to_f / height, 0.1, 100.0
    glMatrixMode GL_MODELVIEW
  end

  def rect x1, y1, x2, y2, t_id
    glBegin GL_QUADS do
      glNormal3f 0,0,1
      glVertex3f x1, y1,  0.0
      glVertex3f x2,  y1,  0.0
      glVertex3f  x2,  y2,  0.0
      glVertex3f  x1, y2,  0.0
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

    end

        glRotatef -90, 1,0,0
        glScalef 0.05, 0.05, 0.05
        60.times do
          glRotate 10,1,0,0
          @svg.draw
        end
      end

      glPushMatrix do
        #glTranslatef 0,0,1
        #glRotatef @a, 1,0,0
        @c = @c.adjust_hue -0.1
        glColor3f *@c.to_a
        #glutSolidSphere 2.0, 20, 20
        end
    end

    # Swap buffers for display
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

    @index = glGenLists 1
    @svg = SVG.new 'images/drawing.svg', @index

    init_gl_window WIDTH, HEIGHT
    
    glutMainLoop
  end
end



Lesson3.new
