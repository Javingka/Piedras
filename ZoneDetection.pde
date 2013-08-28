class ZoneDetection {
  int X1, X2, Y1, Y2;
  int divX;   //el divisor del ancho para obtener el tamaño de cada zona
  int divY;  //el divisor del alto para obtener el tamaño cada zona
  int zonas; //cantidad de zonas
  PImage cam; //la imagen que entrega la camara

  //el ancho y alto de la "zona de deteccion" de la imagen obtenida.
  int detectionWidth; //el ancho de la imagen analizada sera menor que el ancho (640) de la imagen obtenida. 
  int detectionHeight; //el alto de la imagen analizada también será menor que el alto (480)

  //el ancho y el alto de cada una de las áreas de evaluación de imagen
  int interAreaWidth; 
  int interAreaHeight;

  //Array de listas (int) que guardan posiciones de los pixelen por zona como punto de referencia
  IntList [] pixelsRefZone;
  //Array de listas (int) que guardan posiciones de los pixelen por zona en cada momento
  IntList [] pixlesCurrentZone;

  int [] zonesVariation; //Array de ints para almacenar las variaciones de cantidad de pixeles por zona

  //Variables para almacenar el dato de la Zona definida como activa
  int zonaActiva;
  int zonaAnterior;
  int indexZona;
  
  ZoneDetection (int x1, int y1, int x2, int y2, int divisionWidth, int divisionHeight, PImage _cam) {
    X1=x1; //posicion izquierda 
    Y1=y1; //posición superior de la pantalla
    X2=x2; //posicion derecha
    Y2=y2; //posicion inferior de la pantalla
    divX = divisionWidth; //divisor del acho de la imagen para anchos zonales 
    divY = divisionHeight; //divisor del alto de la imagen para altos zonales
    cam = _cam; //PImage donde se almacenaran las imagenes 

    //Tamaños de la zona de deteccion
    detectionWidth = X2-X1;
    detectionHeight = Y2-Y1;

    //el ancho y el alto de cada una de las áreas de evaluación de imagen
    interAreaWidth = detectionWidth / divX;
    interAreaHeight = detectionHeight / divY;

    zonas = (divX*divY);
    pixelsRefZone = new IntList[ zonas ];
    pixlesCurrentZone = new IntList[ zonas ];
    zonesVariation = new int [zonas];
    zonaActiva = 0; //inicializamos en 0 mientras aun no hay lectura de los pixeles
    zonaAnterior = 0;
    indexZona=0;
  }

  
  void readFilterCam () {

    if (camara.available() == true) {
      camara.read();
      camara.filter(THRESHOLD, .5  );
  }
  }
  
  void drawGrid () {
    pushMatrix();
    pushStyle();
    rectMode (CORNERS);

    noFill();
    stroke (10, 120, 0);
    strokeWeight (3);

    rect (X1, Y1, X2, Y2);
    translate (X1, Y1);
    strokeWeight (1);
    stroke (255,0,0);
    for (int ty=0 ; ty < divY ; ty++) {
      for (int tx=0 ; tx < divX ; tx++ ) {
        if (ty != 0 ) line (interAreaWidth * tx, interAreaHeight *ty, interAreaWidth * (tx+1), interAreaHeight * ty);
        if (tx != 0 ) line (interAreaWidth * tx, interAreaHeight *ty, interAreaWidth * (tx), interAreaHeight * (ty+1) );
      }
    }

    popMatrix();
    popStyle();
  }

  void calibrate () {
    pushMatrix();
    pushStyle();
    rectMode (CORNERS);
    cam.loadPixels(); //se llama antes de acceder al array de pixeles, diciendo "carga los pixeles, quiero acceder a ellos"

    int i=0;

    //For para recorrer cada una de las zonas de deteccion (recordar zonas = (divX*divY))
    int cx=0;
    int cy=0;
    for ( int z=0 ; z < zonas ; z++) {
      //Lista donde se almacenará temporalmente la posicion de los pixeles blancos de cada una
      //de las zonas "z", desde 0 hasta el ultimo valor de z.
      IntList listaZonaTemporal = new IntList(); 

      //DEFINICION de variables definir los limites de cada una de las ZONAS a detectar
      cx = z%divX; //la variable cx, queda en un loop entre 0 y el valor de "divX"
      cy = (int) z/divX; //calcula cuantas lineas de X hay, es decir cuantos cuadros en el eje Y

      int leftX = X1 + int (interAreaWidth * cx); //X1 es la distancia entre el borde iz de la imagen y el pixel iz desde donde comenzamos a detectar
      int rightX = X1 + int (interAreaWidth * (cx+1) );
      int upY = Y1 + int (interAreaHeight * cy ); //Y1 es la distancia entre el borde superior de la imagen y el pixel sup desde donde comenzamos a detectar
      int bottomY = Y1 + int (interAreaHeight * (cy+1) );

      //dos BUCLES anidados, para recorrer desde la iz-arriba hasta la der-abajo todos los pixeles de cada zona
      for (int x = leftX ; x < rightX; x++) {
        for (int y = upY; y < bottomY; y++) {
          i = x + y * cam.width; //formula que calcula la posicion del pixel segun las posiciones X e Y
          int v =  cam.pixels[i] & 0xFF; // "v" almacena el valor en escala de grises del pixel
          //RECORDAR que la imagen que se analiza fue filtrada para obtener solo blancos y negros
          
          if (v == 255) {   //si "v" es blanco ( es decir == 255)
            listaZonaTemporal.append(i);//con .append agregamos la posición (i) del pixel a la lista temporal
          }
        }
      }
      //se almacenan los valores de "listaZonaTemporal" dentro del array de listas pixelsRefZone
      //recordar: esta lista almacena la posicion de todos los pixeles blancos
      pixelsRefZone[z] = listaZonaTemporal;
    }

    cam.updatePixels(); //esta funcion se llama despues de haber terminado las variaciones, como diciendo:
    // "Sigamos, ya modifique los pixeles, esta lista la imagen"

    popMatrix();
    popStyle();
  }

  void dataZone (boolean print) {
    pushMatrix();
    pushStyle();
    rectMode (CORNERS);
    textAlign (CENTER, CENTER);
    stroke(255);
    colorMode(HSB);

    //IMPRIMIMOS para tener certeza que nuestra lista contiene datos correctos
    float vColor = 200 / zonas;
    int cx=0;
    int cy=0;
    for ( int z=0 ; z < zonas ; z++) { 
      cx = z%divX; 
      cy = (int) z/divX;

      int leftX = X1 + int (interAreaWidth * cx); 
      int rightX = X1 + int (interAreaWidth * (cx+1) );
      int upY = Y1 + int (interAreaHeight * cy );
      int bottomY = Y1 + int (interAreaHeight * (cy+1) );

      fill (vColor*z, 120, 120, 200);
      rect (leftX, upY, rightX, bottomY);
      if (print) {
        println (" pixelsRefZone"+z+": "+ pixelsRefZone[z].size() ); //imprime la cantidad de pixeles por zona
      }

      stroke(0);
      fill (0); 
      textSize (15);
      text ("Zona"+z+": ", leftX+(interAreaWidth/2), upY+(interAreaHeight/2)-10 );
      text (pixelsRefZone[z].size(), leftX+(interAreaWidth/2), upY+(interAreaHeight/2)+10 );
    }
    if (print) {
      println ("__________________________________");
      println ("Total de zonas calculadas: "+zonas);
    }

    popMatrix();
    popStyle();
  }

  void detectionZones () {

    pushMatrix();
    pushStyle();
    rectMode (CORNERS);
    cam.loadPixels(); //se llama antes de acceder al array de pixeles, diciendo "carga los pixeles, quiero acceder a ellos"

    int i=0;

    //For para recorrer cada una de las zonas de deteccion (recordar zonas = (divX*divY))
    int cx=0;
    int cy=0;
    for ( int z=0 ; z < zonas ; z++) {
      //Lista donde se almacenará temporalmente la posicion de los pixeles blancos de cada una
      //de las zonas "z", desde 0 hasta el ultimo valor de z.
      IntList listaZonaTemporal = new IntList(); 

      //DEFINICION de variables definir los limites de cada una de las ZONAS a detectar
      cx = z%divX; //la variable cx, queda en un loop entre 0 y el valor de "divX"
      cy = (int) z/divX;

      int leftX = X1 + int (interAreaWidth * cx); //X1 es la distancia entre el borde iz de la imagen y el pixel iz desde donde comenzamos a detectar
      int rightX = X1 + int (interAreaWidth * (cx+1) );
      int upY = Y1 + int (interAreaHeight * cy ); //Y1 es la distancia entre el borde superior de la imagen y el pixel sup desde donde comenzamos a detectar
      int bottomY = Y1 + int (interAreaHeight * (cy+1) );

      //dos BUCLES anidados, para recorrer desde la iz-arriba hasta la der-abajo todos los pixeles de cada zona
      for (int x = leftX ; x < rightX; x++) {
        for (int y = upY; y < bottomY; y++) {
          i = x + y * cam.width; //formula que calcula la posicion del pixel segun las posiciones X e Y
          int v =  cam.pixels[i] & 0xFF; // "v" almacena el valor en escala de grises del pixel
          //RECORDAR que la imagen que se analiza fue filtrada para obtener solo blancos y negros
          //          int vColor = 255 / zonas;
          if (v == 255) listaZonaTemporal.append(i);//con .append agregamos la posición (i) del pixel a la lista temporal
        }
      }
      //se almacenan los valores de "listaZonaTemporal" dentro del array de listas pixelsRefZone
      //recordar: esta lista almacena la posicion de todos los pixeles blancos
      pixlesCurrentZone[z] = listaZonaTemporal;
    }

    cam.updatePixels(); //esta funcion se llama despues de haber terminado las variaciones, como diciendo:
    // "Sigamos, ya modifique los pixeles, esta lista la imagen"

    popMatrix();
    popStyle();
  }


  void zonesAnalysis (boolean see, int ua, int uc) {
    int tempZonaActiva = 0 ;
    int tempIndexZona =0;
    int umbralActivacion = ua; //el umbral para establecer cuantos pixeles son necesarios que cambien para
    //activar una Zona
    int umbralCambio = uc; //el umbral para establecer cuantos pixeles son necesarios que cambien
    //para establecer una nueva zona de activacion
    
    zonaAnterior = zonaActiva;

    for ( int z=0 ; z < zonas ; z++) {
      int tempDif = abs ( pixelsRefZone[z].size() - pixlesCurrentZone[z].size() );
      zonesVariation [z] =tempDif;
    }

    for ( int z=0 ; z < zonas ; z++) { 
      //    println ("tdifBlob"+s+": "+ difBlob[s] );
      if (zonesVariation[z] > tempZonaActiva) {
        tempZonaActiva = zonesVariation[z];
        tempIndexZona = z;
      }
    }

    int cal = abs (tempZonaActiva - zonaAnterior);//diferencia entre la temporal zona activa y la zona anterior
    
    //si la maxima variacion (tempZonaActiva) no es mayor que "umbralActivacion" no se toma en cuenta
    //y vuelve a estado inicial
    if (tempZonaActiva < umbralActivacion ) {
      zonaActiva = 0;
      indexZona = -1;
    }
    //Ahora si la diferencia entre la temporal zona activa y la zona anterior es mayor a 1000
    //solo entonces se reescribe la zona activa "oficial"
    else if (  cal > umbralCambio ) {
      zonaActiva = tempZonaActiva;
      indexZona = tempIndexZona;
    }

    if (see) {
      println ( "zonaActiva: " + zonaActiva);
      println ( "indexZona: " + indexZona);
    }
  }
  
  void viewActiveZone () {
    pushMatrix();
    pushStyle();
    rectMode (CORNERS);
    textAlign (CENTER, CENTER);
    
    int cx = indexZona%divX; //la variable cx, queda en un loop entre 0 y el valor de "divX"
    int cy = indexZona/divX; //cuando cx es 0 la variable cy se suma en uno

      int leftX = X1 + int (interAreaWidth * cx); //X1 es la distancia entre el borde iz de la imagen y el pixel iz desde donde comenzamos a detectar
      int rightX = X1 + int (interAreaWidth * (cx+1) );
      int upY = Y1 + int (interAreaHeight * cy ); //Y1 es la distancia entre el borde superior de la imagen y el pixel sup desde donde comenzamos a detectar
      int bottomY = Y1 + int (interAreaHeight * (cy+1) );
      
    fill (120,50,200, 150);
    rect (leftX, upY, rightX, bottomY);
    fill (0);
    textSize(15);
    text ("Zona Activa", leftX+(interAreaWidth/2), upY+(interAreaHeight/2)-40 );
    textSize(10);
    text ("variacion de: ", leftX+(interAreaWidth/2), upY+(interAreaHeight/2)+25 );
    text (zonaActiva, leftX+(interAreaWidth/2), upY+(interAreaHeight/2)+38 );
    
  popMatrix();
  popStyle();
  }
  
  int getActiveZone () {
    return indexZona;
  }
  
  
}
