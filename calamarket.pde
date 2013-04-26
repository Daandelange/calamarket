// Mainly coded by Daan de Lange (http://daandelange.com/)
// Tentacles based on Edward Porten's Undersea Creature (http://www.openprocessing.org/sketch/11104)
// Improved by Fanny (looktheodderway.net)

// i iz so sorry, comments are half in french, half in english :p
// maybe lolcat translated them :p

// there's some very very dirty code, be prepared :p

import processing.opengl.*;
import processing.video.*;

PImage circle, img_manon, img_graphisme;
Movie bg_movie;

// variables pas-touche
PVector o_velocity, o_position;
PVector circle_img_noise_offset = new PVector(0,0);
int[] circle_alpha;
int time_since_last_user_input=0;

// config animation mouvement
float acceleration = 0.001;
float max_speed = .05;
int timeout = 5000; // number of frames before the computer starts animating the sea creature
boolean debug = false; // setting this to true can help you

void setup()
{
  size(900, 900, OPENGL);
  frameRate(24); // restrict framerate to 24
  smooth();
  noStroke();
  noiseDetail(3,0.7);
  
  // load circle's alpha channel
  circle = loadImage("circle.png");
  circle.loadPixels();
  circle_alpha = new int[circle.pixels.length];
  for(int i=0; i<circle.pixels.length; i++){
    circle_alpha[i] = (int)alpha(circle.pixels[i]);
  }
  
  // get circle image
  img_manon = loadImage("img_circle.jpg");
  img_manon.resize(img_manon.width/2, img_manon.height/2);
  
  // load the bg movie
  bg_movie = new Movie(this, "bg_movie.mov");
  bg_movie.loop();

  // positionnement de la meduse
  o_velocity = new PVector(0, 0);
  o_position = new PVector(0, 0); // entre -1 et 1

}

// thanks to Edward Porten
void DrawCreature( float t, float r, float space, int numtents)
{
  int scale = 2;
  pushMatrix();
  scale(scale); // 100% dirty
  translate(-width/(2*scale), -height/(2*scale));
  int dv = (int) floor(sqrt(numtents));  // reduce amt depending on numtents

  int waterSnake = 512/dv; //degrade de formes des tentacules
  
  float gimme_x=0, gimme_y=0;// 100% cheating
  
  for (int i = waterSnake-1; i>=0; i--)
  {
    float v = (float)i/(float)waterSnake;
    float b =1.-v;
    b*=b;
    b*=b;
    fill(190,20); //couleur bestiole

    float radius = (sqrt((1.-v)) * 1 + b*b*2.)*r;
    radius-=8; // dirty fix
    
    for (int j =0 ;j < numtents;j++)
    {
      float ang = (float)j/(float)1; //angle origine tentacules
      float xang = sin(ang)*v; // rotate from zero in noise space
      float yang = cos(ang)*v; // so all have same starting value
 
      float x = noise(xang- t*1, yang-t*0.5)*1.-.5; //deplacement lateral
      float y = noise(yang- t + 150, xang -t*.5)*1.-.5; //deplacement vertical
      
      
      if(time_since_last_user_input < timeout){
        // insert manual movement
        x =
          x*.2 + o_position.x*.8 // 80% position manuelle + 20% de random
          + (v*x); // les tentacules sont plus influencés que le centre
        y = y*.2 + o_position.y*.8 + (v*y);
      }
      
      ellipse( x * width/2*space + width/2, y * height/2*space + height/2, radius, radius);
      
      if(i==0){
        gimme_x = x;
        gimme_y = y;

      }
      
    }
  }
  
  
  
  // update circle image position
  circle_img_noise_offset.add(new PVector(random(0.002, 0.01), random(0.002, 0.01) ));
  
  // get circle image and randomize it's position
  img_graphisme = img_manon.get(
    round(noise(circle_img_noise_offset.x)*(img_manon.width-circle.width)),
    round(noise(circle_img_noise_offset.y)*(img_manon.height-circle.height)),
    circle.width, circle.height);
  img_graphisme.mask(circle);
  
  // display it
  ellipse(gimme_x*width/2*space + width/2, gimme_y * height/2*space + height/2, 130, 130);
  image (img_graphisme, gimme_x*width/2*space + width/2 - circle.width/2, gimme_y * height/2*space + height/2 - circle.height/2);
  
  popMatrix();
}

float g_speedT = 0;
float g_PrevT = 20;
int numTenticales = 8;
 

void draw(){
  //background(0);
  image(bg_movie,0,0,width, height);
  
  
  float t = (float) millis()/1000.0f;
  float dt = t -g_PrevT;
  float spd =  0.05+ random(0,0.5);
  g_speedT += dt * spd;
  g_PrevT = t;
  
  noStroke();
  DrawCreature(g_speedT,45,1,numTenticales); // (speed,taille tête, taille tentacule, nombre tentacule)
  
  fill(255);
  if(debug) text(frameRate, 10, 20); // affichage des FPS
  
  o_position.add(o_velocity);
  o_velocity.mult(.99); // ralentit le mouvement à chaque image
  
  // restrict to visible area
  if(o_position.x < -1) o_position.x=-1;
  else if(o_position.x > 1) o_position.x=1;
  
  if(o_position.y < -1) o_position.y=-1;
  else if(o_position.y > .93) o_position.y=.93;
  
  time_since_last_user_input++;
}

// Called every time a new frame is available to read
void movieEvent(Movie m) {
  m.read();
}
