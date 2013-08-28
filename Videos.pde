class Videos {

  Movie [] videosDin; //un array que almacenara los  objetos del tipo "Moive"
  int videosCant;
  boolean [] playing; //booleana para determinar cual video esta siendo reproducido

  Videos (int movieCant, PApplet pp) {
    videosCant = movieCant; //establece la cantidad de videos
    videosDin = new Movie [movieCant];
    playing = new boolean [movieCant];

    //se almacena en el array cada una de los videos. Importante en este caso el 
    //nombre de los videos tiene que ser así : "test(un numero).mp4"
    for ( int v=0 ; v < movieCant ; v++ ) {
      videosDin[v] = new Movie ( pp, "test"+(v+1)+".mp4" );
    }
    
   // println ("videosDin: "+videosDin[0]);
  }

  void placeVideos () {
    
     for ( int i=0 ; i < videosCant ; i++ ) {
       
      if (i == zonas.indexZona) {
        playing[i] = true;
      }
      else {
        playing[i] = false;
      }

      videoResize (playing[i], i);
    }
  }
  
  void videoResize (boolean play, int i) {
    pushMatrix();
    pushStyle();
    imageMode (CENTER);
    
//    println ("outN: "+i);
    if ( play ) {
//     println ("        VideoN: "+i);
     videosDin[i].play();
     image (videosDin[i], width*.5, height*.5, 320, 240); 
    }
    else videosDin[i].stop();
  
  popMatrix();
  popStyle();
  }
  

  
  
}
