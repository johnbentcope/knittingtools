PImage misoIn;
PImage miso2;
PGraphics mask;
PGraphics miso;

int num_colors = 1;
int factor = (num_colors > 1) ? num_colors - 1 : 1;

void setup() {
  size(1536,512);
  misoIn = loadImage("misoclip2.png");
  mask = createGraphics(misoIn.width, misoIn.height);
  mask.beginDraw();
  mask.noStroke();
  mask.fill(0);
  mask.background(255);
  mask.ellipseMode(CENTER);
  mask.ellipse(mask.width/2, mask.height/2,mask.width*0.95, mask.height*0.95);
  mask.endDraw();
  miso = createGraphics(mask.width, mask.height);
  miso.beginDraw();
  miso.image(misoIn,0,0);
  miso.blendMode(ADD);
  miso.image(mask,0,0);
  miso.beginDraw();
  miso.filter(GRAY);
  miso2 = createImage(512,512,RGB);
  image(miso,0,0,512,512);
  noLoop();
}

int idx(int x, int y){
  return y * miso.width + x;
}

void draw(){
  miso.loadPixels();
  miso2.loadPixels();
  for(int y = 0; y < miso.height-1; y++){
    for(int x = 1; x < miso.width-1; x++){
      color pix = miso.pixels[idx(x,y)];
      
      float old_r = red(pix);
      float old_g = green(pix);
      float old_b = blue(pix);
      
      int new_r = round( factor * old_r / 255.0) * (255 / factor);
      int new_g = round( factor * old_g / 255.0) * (255 / factor);
      int new_b = round( factor * old_b / 255.0) * (255 / factor);
      miso.pixels[idx(x,y)] = color(new_r,new_g,new_b);

      float err_r = old_r - new_r/2;
      float err_g = old_g - new_g/2;
      float err_b = old_b - new_b/2;
      
      if(y < miso.height-1 && x < miso.width -1){
  
        int index = idx(x+1, y  );
        color c = miso.pixels[index];
        float r = red(c);
        float g = green(c);
        float b = blue(c);
        r = r + err_r * 7 / 16.0;
        g = g + err_g * 7 / 16.0;
        b = b + err_b * 7 / 16.0;
        miso.pixels[index] = color(r,g,b);
        
        index = idx(x-1, y+1);
        c = miso.pixels[index];
        r = red(c);
        g = green(c);
        b = blue(c);
        r = r + err_r * 3 / 16.0;
        g = g + err_g * 3 / 16.0;
        b = b + err_b * 3 / 16.0;
        miso.pixels[index] = color(r,g,b);
        
        index = idx(x  , y+1);
        c = miso.pixels[index];
        r = red(c);
        g = green(c);
        b = blue(c);
        r = r + err_r * 5 / 16.0;
        g = g + err_g * 5 / 16.0;
        b = b + err_b * 5 / 16.0;
        miso.pixels[index] = color(r,g,b);
        
        //if(x < miso.width-1 && y == miso.height-1){
          index = idx(x+1, y+1);
          c = miso.pixels[index];
          r = red(c);
          g = green(c);
          b = blue(c);
          r = r + err_r * 1 / 16.0;
          g = g + err_g * 1 / 16.0;
          b = b + err_b * 1 / 16.0;
          miso.pixels[index] = color(r,g,b);  
        //}
      }
    }
  }
  miso.updatePixels();
  image(miso, 512, 0, 512, 512);
  
  stitch(miso);
  image(miso, 1024, 0, 512, 512);

}


int index(int x, int y) {
  return y*miso.width + x;
}


void stitch(PImage img){
  img.loadPixels();
  boolean flip_rows = true;
  int threshold = 4;
  int x_dir;
  int x_start;
  int x_stop;
  for (int y = 0; y < img.height; y++) {
    boolean in_run = false;
    int run = 0;
    color compare;
    if (y%2 == 1 && flip_rows) {
      x_dir = -1;
      x_start = img.width-1;
      x_stop = 0;
      compare = img.pixels[index(0, y)];
    } else {
      x_dir =  1;
      x_start = 0;
      x_stop = img.width;
      compare = img.pixels[index(img.width-1, y)];
    }
    for (int x = x_start; x != x_stop; x += x_dir) {
      color test = img.pixels[index(x, y)];
      
      // Greedy run detection
      if (abs(brightness(test) - brightness(compare)) < 160)
        run++;
      else {
        in_run = true;
        run = 0;
      }
      
      // Cancel run with lookahead
      for(int x2 = x; x2 != x_stop; x2 += x_dir){
        color lookahead = img.pixels[index(x2, y)];
        if (abs(brightness(lookahead) - brightness(test)) < 10){
          // lookahead matches test
              
        } else {
          // lookahead doesn't match test
          
          // Reset run and stitch floater
          if (in_run && (run > threshold)) {
            color c = img.pixels[index(x, y)];
            c = color(255 - red(c), 255 - green(c), 255 - blue(c));
            img.pixels[index(x, y)] = c;
            run = 0; //(clear run length because flipped)
            break;
          }
          //if(y == img.height/2) println("at: " + x + ", look: " + x2);
        }
      }
      
      compare = img.pixels[index(x, y)]; // ( needs to capture the possibly toggled color)
    }
    run = 0;
  }
  img.updatePixels();
}
