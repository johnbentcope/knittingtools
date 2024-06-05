int[][] kernel = new int[][] {
    { 0 * 255 / 16,  8 * 255 / 16,  2 * 255 / 16, 10 * 255 / 16},
    {15 * 255 / 16,  7 * 255 / 16, 13 * 255 / 16,  5 * 255 / 16},
    { 3 * 255 / 16, 12 * 255 / 16,  1 * 255 / 16,  9 * 255 / 16},
    {11 * 255 / 16,  4 * 255 / 16, 14 * 255 / 16,  6 * 255 / 16}
};


PImage miso;
PImage out;

void setup(){
  size(1024,512);
  miso = loadImage("misoclip2.png");
  out = createImage(512,512,RGB);
}

int i(int x, int y){
  return y*miso.width + x;
}

int k(int x, int y){
  return kernel[y%4][x%4];
}

void draw(){
  image(miso,0,0);
  miso.loadPixels();
  out.loadPixels();
  
  
  for(int y = 0; y < miso.height; y++){
    for(int x = 0; x < miso.width; x++){
      color c = miso.pixels[i(x,y)];
      if (brightness(c) > k(x,y)){
        out.pixels[i(x,y)] = color(255);
      } else {
        out.pixels[i(x,y)] = color(0);
      }
    }
  }

  out.updatePixels();
  image(out,miso.width,0);
}
