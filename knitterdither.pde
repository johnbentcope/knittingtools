PImage img;
boolean flip_rows = false;

void setup() {
  size(450, 225);
  img = loadImage("test3.png");
  image(img,0,0);
  img.loadPixels();
  int threshold = 4;
  int x_dir;
  int x_start;
  int x_stop;
  for (int y = 0; y < img.height; y++) {
    boolean in_run = false;
    boolean run_ends = false;
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
      if (abs(brightness(test) - brightness(compare)) < 10)
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
          run_ends = true;
          if(y == img.height/2) println("at: " + x + ", look: " + x2);
        }
      }
      //if(!run_ends) in_run = false;
      
      // Reset run and stitch floater
      if (in_run && (run > threshold) && !run_ends) {
        color c = img.pixels[index(x, y)];
        c = color(255 - red(c), 255 - green(c), 255 - blue(c));
        img.pixels[index(x, y)] = c;
        run = 0; //(clear run length because flipped)
      }
      compare = img.pixels[index(x, y)]; // ( needs to capture the possibly toggled color)
    }
    run = 0;
  }
  img.updatePixels();
  image(img, img.width, 0);
}

int index(int x, int y) {
  return y*img.width + x;
}

void draw() {

  surface.setTitle("Dither Knitter");
}

