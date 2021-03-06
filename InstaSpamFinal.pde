
// I have started with the InstaSpam-file and
// have edited it to make a more appealing application
// that runs on Facebook

/* @pjs preload="media/photo.jpg"; */

// the image that is being edited
PImage originalImage;

// images to use for button logos
PImage facebookLogo, cameraLogo, rotateLogo;

// the overlay images that can be applied to the image
PImage [] overlays;
// images for the tint buttons
PImage [] tintImages;

// the tint colors we can apply
color [] tints; 

// radio buttons to trigger tints and overlays
RadioButtons tintButtons;
RadioButtons overlayButtons;

// button to load a file from the camera or file
Button fileButton;
// button to post to Facebook
Button FBButton;

Button rotateButton;

// whether the user interface is showing
boolean displayGUI = false;

// this stops you showing a file temporarily as
// we load a new file
boolean updateImage = false;

// post to facebook next frame
boolean post = false;

// the angle of rotation of the image
float angle = 0;

// the position of the center of the image, 
// this allows you to scroll it around
int imageCenterX;

// loads a new image when you get one from the camera
void setImage(String url) {
  //console.log("loading: "+url);
  originalImage  = loadImage(url);
  updateImage = true;
  loop();
}

void setup()
{
  size(600, 600);

  imageCenterX = width/2;
  originalImage = loadImage("media/photo.jpg");
  facebookLogo = loadImage("media/facebookLogo.png");
  cameraLogo = loadImage("media/cameraLogo.png");
  rotateLogo = loadImage("media/rotateLogo.png");

  tints = new color[3]; 
  tints[0] = color(255, 0 ,0);
  tints[1] = color(180, 0, 0);
  tints[2] = color(255, 205, 205);

  tintImages = new PImage[3];
  tintImages[0] = loadImage("media/tintImage0.png");
  tintImages[1] = loadImage("media/tintImage1.png");
  tintImages[2] = loadImage("media/tintImage2.png");

  overlays = new PImage[3];
  overlays[0] = loadImage("media/overlay0.png");
  overlays[1] = loadImage("media/overlay1.png");
  overlays[2] = loadImage("media/overlay2.png");

  overlayButtons = new RadioButtons(overlays.length, 5, height-65, 60, 60, HORIZONTAL); 
  for (int i = 0; i < overlays.length; i++)
  {  
    // sets the image for the button to be the same as the overlay itself
    overlayButtons.setImage(i, overlays[i]);
    // sets the colors to use for the outline
    // the inactive color is transparent so the border is invisible
    overlayButtons.buttons[i].setInactiveColor(color(255, 255, 255, 0));
    overlayButtons.buttons[i].setActiveColor(color(255));
  }

  tintButtons = new RadioButtons(tints.length, 200, height-65, 60, 60, HORIZONTAL); 
  for (int i = 0; i < tints.length; i++)
  {
    // sets the image for the button to be the same as the main image
    tintButtons.setImage(i, tintImages[i]);
    // set a tint for the button to be the same as tint i
    //tintButtons.buttons[i].setImageTint(tints[i]);
    // sets the colors to use for the outline
    // the inactive color is transparent so the border is invisible
    tintButtons.buttons[i].setInactiveColor(color(255, 0));
    tintButtons.buttons[i].setActiveColor(color(255));
  }

  // create buttons for file loading and facebook posting
  // load logos for each

  rotateButton = new Button ("rotate", width-195, height-65, 60, 60);
  rotateButton.setImage(rotateLogo);
  rotateButton.setInactiveColor(color(255, 255, 255, 0));
  fileButton = new Button ("file", width-130, height-65, 60, 60);
  fileButton.setImage(cameraLogo);
  fileButton.setInactiveColor(color(255, 255, 255, 0));
  FBButton = new Button ("FB", width-65, height-65, 60, 60);
  FBButton.setImage(facebookLogo);
  FBButton.setInactiveColor(color(255, 255, 255, 0));
}

void draw()
{
  background(100);

  // don't display the image if you have just updated the image
  if (! updateImage)
  {
    pushStyle();
    // if we have selected a tint tintButtons.get will be positive
    // if so apply a tint

    if (tintButtons.get() >= 0)
    {
      tint(tints[tintButtons.get()]);
    }

    // rescale the image so that it is the full height of the screen
    float imageWidth = (height*originalImage.width)/originalImage.height;

    // draw the image
    imageMode(CENTER);
    pushMatrix();
    translate(imageCenterX, height/2);
    rotate(angle);
    image(originalImage, 0, 0, imageWidth, height);
    popMatrix();
    // turn the tint off for the overlay

    // if we have selected a tint tintButtons.get will be positive
    // if so draw the overlay
    if (overlayButtons.get() >= 0)
    {
      image(overlays[overlayButtons.get()], width/2, height/2, width, height);
    }
    popStyle();


    // if we are displaying the user interface, draw it
    if (displayGUI)
    {
      // draw a transparent rectangle behind the UI to make it
      // more visible
      pushStyle();
      fill(255, 231, 230, 200);
      noStroke();
      rect(0, height - 70, width, 70);


      // draw all the UI elements
      tintButtons.display();
      overlayButtons.display();
      FBButton.display();
      fileButton.display();
      rotateButton.display();
      noTint();
      popStyle();
    }
    // post is set to true
    // when the user hits the facebook button
    if (post)
    {
      $("#yada").click();
      post = false;
    }
  }
  else // if we are updating the image, just draw some text
  {
    textAlign(CENTER, CENTER);
    text("updating", width/2, width/2);
    // stop the update message once we have drawn it once
    float imageWidth = (height*originalImage.width)/originalImage.height;

    originalImage.resize(imageWidth, height);
    updateImage = false;
  }
}

// respond to user interface events
void mouseReleased()
{
  // first we need to check if the user interface is show
  // if it is we can trigger events. Otherwise the click
  // will show the interface
  if (displayGUI)
  {
    // if we are in the interface area at the bottom of the 
    // screen we trigger the UI events
    if (mouseY > height - 60)
    {
      tintButtons.mouseReleased();
      overlayButtons.mouseReleased();

      if (FBButton.mouseReleased())
      {
        //      println("hello");
        // we delay the posting to facebook so that we can 
        // hide the interface before we post it! 
        // so se set this variable to true
        // hude the GUI, then post... see the draw method
        post = true;
        displayGUI = false;
      }
      if (fileButton.mouseReleased())
      {
        // println("now we call selectFile, defined in insta.js");
       selectFile();

        displayGUI = false;
      }
      if (rotateButton.mouseReleased())
      {
        angle += radians(90);
        displayGUI = false;
      }
    }
    //else  
    {
      // if we clicked in the middle of
      // the screen, hide the UI
      displayGUI = false;
    }
  }
  else
  {
    // if the UI was hidden, a click will show it
    displayGUI = true;
  }
}

// when we dragg we can move the image from left to
// right (it is the full screen height so we don't want
// to move it up and down)
void mouseDragged()
{
  imageCenterX += mouseX - pmouseX;
}


int HORIZONTAL = 0;
int VERTICAL   = 1;
int UPWARDS    = 2;
int DOWNWARDS  = 3;

class Widget
{

  
  PVector pos;
  PVector extents;
  String name;

  color inactiveColor = color(60, 60, 100);
  color activeColor = color(100, 100, 160);
  color bgColor = inactiveColor;
  color lineColor = color(255);
  
  
  
  void setInactiveColor(color c)
  {
    inactiveColor = c;
    bgColor = inactiveColor;
  }
  
  color getInactiveColor()
  {
    return inactiveColor;
  }
  
  void setActiveColor(color c)
  {
    activeColor = c;
  }
  
  color getActiveColor()
  {
    return activeColor;
  }
  
  void setLineColor(color c)
  {
    lineColor = c;
  }
  
  color getLineColor()
  {
    return lineColor;
  }
  
  String getName()
  {
    return name;
  }
  
  void setName(String nm)
  {
    name = nm;
  }


  Widget(String t, int x, int y, int w, int h)
  {
    pos = new PVector(x, y);
    extents = new PVector (w, h);
    name = t;
    //registerMethod("mouseEvent", this);
  }

  void display()
  {
  }

  boolean isClicked()
  {
    if (mouseX > pos.x && mouseX < pos.x+extents.x 
      && mouseY > pos.y && mouseY < pos.y+extents.y)
    {
      //println(mouseX + " " + mouseY);
      return true;
    }
    else
    {
      return false;
    }
  }
  
  public void mouseEvent(MouseEvent event)
  {
    //if (event.getFlavor() == MouseEvent.PRESS)
    //{
    //  mousePressed();
    //}
  }
  
  
  boolean mousePressed()
  {
    return isClicked();
  }
  
  boolean mouseDragged()
  {
    return isClicked();
  }
  
  
  boolean mouseReleased()
  {
    return isClicked();
  }
}

class Button extends Widget
{
  PImage activeImage = null;
  PImage inactiveImage = null;
  PImage currentImage = null;
  color imageTint = color(255);
  
  Button(String nm, int x, int y, int w, int h)
  {
    super(nm, x, y, w, h);
  }
  
  void setImage(PImage img)
  {
    setInactiveImage(img);
    setActiveImage(img);
  }
  
  void setInactiveImage(PImage img)
  {
    if(currentImage == inactiveImage || currentImage == null)
    {
      inactiveImage = img;
      currentImage = inactiveImage;
    }
    else
    {
      inactiveImage = img;
    }
  }
  
  void setActiveImage(PImage img)
  {
    if(currentImage == activeImage || currentImage == null)
    {
      activeImage = img;
      currentImage = activeImage;
    }
    else
    {
      activeImage = img;
    }
  }
  
  void setImageTint(color c)
  {
    imageTint = c;
  }

  void display()
  {
    if(currentImage != null)
    {
      //float imgHeight = (extents.x*currentImage.height)/currentImage.width;
      float imgWidth = (extents.y*currentImage.width)/currentImage.height;
      
      
      pushStyle();
      imageMode(CORNER);
      //tint(imageTint);
      image(currentImage, pos.x, pos.y, imgWidth, extents.y);
      stroke(bgColor);
      noFill();
      rect(pos.x, pos.y, imgWidth,  extents.y);
      //noTint();
      popStyle();
    }
    else
    {
      pushStyle();
      stroke(lineColor);
      fill(bgColor);
      rect(pos.x, pos.y, extents.x, extents.y);
  
      fill(lineColor);
      textAlign(CENTER, CENTER);
      text(name, pos.x + 0.5*extents.x, pos.y + 0.5* extents.y);
      popStyle();
    }
  }
  
  boolean mousePressed()
  {
    if (super.mousePressed())
    {
      bgColor = activeColor;
      if(activeImage != null)
        currentImage = activeImage;
      return true;
    }
    return false;
  }
  
  boolean mouseReleased()
  {
    if (super.mouseReleased())
    {
      bgColor = inactiveColor;
      if(inactiveImage != null)
        currentImage = inactiveImage;
      return true;
    }
    return false;
  }
}

class Toggle extends Button
{
  boolean on = false;

  Toggle(String nm, int x, int y, int w, int h)
  {
    super(nm, x, y, w, h);
  }


  boolean get()
  {
    return on;
  }

  void set(boolean val)
  {
    on = val;
    if (on)
    {
      bgColor = activeColor;
      if(activeImage != null)
        currentImage = activeImage;
    }
    else
    {
      bgColor = inactiveColor;
      if(inactiveImage != null)
        currentImage = inactiveImage;
    }
  }

  void toggle()
  {
    set(!on);
  }

  
  boolean mousePressed()
  {
    return super.isClicked();
  }

  boolean mouseReleased()
  {
    if (super.mouseReleased())
    {
      toggle();
      return true;
    }
    return false;
  }
}

class RadioButtons extends Widget
{
  public Toggle [] buttons;
  
  RadioButtons (int numButtons, int x, int y, int w, int h, int orientation)
  {
    super("", x, y, w*numButtons, h);
    buttons = new Toggle[numButtons];
    for (int i = 0; i < buttons.length; i++)
    {
      int bx, by;
      if(orientation == HORIZONTAL)
      {
        bx = x+i*(w+5);
        by = y;
      }
      else
      {
        bx = x;
        by = y+i*(h+5);
      }
      buttons[i] = new Toggle("", bx, by, w, h);
    }
  }
  
  void setNames(String [] names)
  {
    for (int i = 0; i < buttons.length; i++)
    {
      if(i >= names.length)
        break;
      buttons[i].setName(names[i]);
    }
  }
  
  void setImage(int i, PImage img)
  {
    setInactiveImage(i, img);
    setActiveImage(i, img);
  }
  
  void setAllImages(PImage img)
  {
    setAllInactiveImages(img);
    setAllActiveImages(img);
  }
  
  void setInactiveImage(int i, PImage img)
  {
    buttons[i].setInactiveImage(img);
  }

  
  void setAllInactiveImages(PImage img)
  {
    for (int i = 0; i < buttons.length; i++)
    {
      buttons[i].setInactiveImage(img);
    }
  }
  
  void setActiveImage(int i, PImage img)
  {
    buttons[i].setActiveImage(img);
  }
  
  
  
  void setAllActiveImages(PImage img)
  {
    for (int i = 0; i < buttons.length; i++)
    {
      buttons[i].setActiveImage(img);
    }
  }

  void set(String buttonName)
  {
    for (int i = 0; i < buttons.length; i++)
    {
      if(buttons[i].getName().equals(buttonName))
      {
        buttons[i].set(true);
      }
      else
      {
        buttons[i].set(false);
      }
    }
  }
  
  int get()
  {
    for (int i = 0; i < buttons.length; i++)
    {
      if(buttons[i].get())
      {
        return i;
      }
    }
    return -1;
  }
  
  String getString()
  {
    for (int i = 0; i < buttons.length; i++)
    {
      if(buttons[i].get())
      {
        return buttons[i].getName();
      }
    }
    return "";
  }

  void display()
  {
    for (int i = 0; i < buttons.length; i++)
    {
      buttons[i].display();
    }
  }

  boolean mousePressed()
  {
    for (int i = 0; i < buttons.length; i++)
    {
      if(buttons[i].mousePressed())
      {
        return true;
      }
    }
    return false;
  }
  
  boolean mouseDragged()
  {
    for (int i = 0; i < buttons.length; i++)
    {
      if(buttons[i].mouseDragged())
      {
        return true;
      }
    }
    return false;
  }

  boolean mouseReleased()
  {
    for (int i = 0; i < buttons.length; i++)
    {
      if(buttons[i].mouseReleased())
      {
        for(int j = 0; j < buttons.length; j++)
        {
          if(i != j)
            buttons[j].set(false);
        }
        //buttons[i].set(true);
        return true;
      }
    }
    return false;
  }
}

class Slider extends Widget
{
  float minimum;
  float maximum;
  float val;
  int textWidth = 60;
  int orientation = HORIZONTAL;

  Slider(String nm, float v, float min, float max, int x, int y, int w, int h, int ori)
  {
    super(nm, x, y, w, h);
    val = v;
    minimum = min;
    maximum = max;
    orientation = ori;
    if(orientation == HORIZONTAL)
      textWidth = 60;
    else
      textWidth = 20;
  }

  float get()
  {
    return val;
  }

  void set(float v)
  {
    val = v;
    val = constrain(val, minimum, maximum);
  }

  void display()
  {
    pushStyle();
    textAlign(LEFT, TOP);
    fill(lineColor);
    text(name, pos.x, pos.y);
    stroke(lineColor);
    noFill();
    if(orientation ==  HORIZONTAL){
      rect(pos.x+textWidth, pos.y, extents.x-textWidth, extents.y);
    } else {
      rect(pos.x, pos.y+textWidth, extents.x, extents.y-textWidth);
    }
    noStroke();
    fill(bgColor);
    float sliderPos; 
    if(orientation ==  HORIZONTAL){
        sliderPos = map(val, minimum, maximum, 0, extents.x-textWidth-4); 
        rect(pos.x+textWidth+2, pos.y+2, sliderPos, extents.y-4);
    } else if(orientation ==  VERTICAL || orientation == DOWNWARDS){
        sliderPos = map(val, minimum, maximum, 0, extents.y-textWidth-4); 
        rect(pos.x+2, pos.y+textWidth+2, extents.x-4, sliderPos);
    } else if(orientation == UPWARDS){
        sliderPos = map(val, minimum, maximum, 0, extents.y-textWidth-4); 
        rect(pos.x+2, pos.y+textWidth+2 + (extents.y-textWidth-4-sliderPos), extents.x-4, sliderPos);
    };
    popStyle();
  }

  
  boolean mouseDragged()
  {
    if (super.mouseDragged())
    {
      if(orientation ==  HORIZONTAL){
        set(map(mouseX, pos.x+textWidth, pos.x+extents.x-4, minimum, maximum));
      } else if(orientation ==  VERTICAL || orientation == DOWNWARDS){
        set(map(mouseY, pos.y+textWidth, pos.y+extents.y-4, minimum, maximum));
      } else if(orientation == UPWARDS){
        set(map(mouseY, pos.y+textWidth, pos.y+extents.y-4, maximum, minimum));
      };
      return true;
    }
    return false;
  }

  boolean mouseReleased()
  {
    if (super.mouseReleased())
    {
      if(orientation ==  HORIZONTAL){
        set(map(mouseX, pos.x+textWidth, pos.x+extents.x-10, minimum, maximum));
      } else if(orientation ==  VERTICAL || orientation == DOWNWARDS){
        set(map(mouseY, pos.y+textWidth, pos.y+extents.y-10, minimum, maximum));
      } else if(orientation == UPWARDS){
        set(map(mouseY, pos.y+textWidth, pos.y+extents.y-10, maximum, minimum));
      };
      return true;
    }
    return false;
  }
}

class MultiSlider extends Widget
{
  Slider [] sliders;

  MultiSlider(String [] nm, float min, float max, int x, int y, int w, int h, int orientation)
  {
    super(nm[0], x, y, w, h*nm.length);
    sliders = new Slider[nm.length];
    for (int i = 0; i < sliders.length; i++)
    {
      int bx, by;
      if(orientation == HORIZONTAL)
      {
        bx = x;
        by = y+i*h;
      }
      else
      {
        bx = x+i*w;
        by = y;
      }
      sliders[i] = new Slider(nm[i], 0, min, max, bx, by, w, h, orientation);
    }
  }

  void set(int i, float v)
  {
    if(i >= 0 && i < sliders.length)
    {
      sliders[i].set(v);
    }
  }
  
  float get(int i)
  {
    if(i >= 0 && i < sliders.length)
    {
      return sliders[i].get();
    }
    else
    {
      return -1;
    }
    
  }

  void display()
  {
    for (int i = 0; i < sliders.length; i++)
    {
      sliders[i].display();
    }
  }

  
  boolean mouseDragged()
  {
    for (int i = 0; i < sliders.length; i++)
    {
      if(sliders[i].mouseDragged())
      {
        return true;
      }
    }
    return false;
  }

  boolean mouseReleased()
  {
    for (int i = 0; i < sliders.length; i++)
    {
      if(sliders[i].mouseReleased())
      {
        return true;
      }
    }
    return false;
  }
}


