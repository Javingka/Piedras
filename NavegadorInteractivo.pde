/*
Navegador Interactivo de Videos por JavierCruz 
 Este programa permite hacer una navegación interactiva por x cantidad de videos
 Se necesita una camara Web y tener los videos en la carpeta "data" anidada 
 en la carpeta raiz de la programacion.
 
 Para Calibrar la programación, precione la tecla "c" una vez corrido el programa, asegurese
 que la superficie de la mesa tiene las piedras esparcidas homogeneamente
 Para mostrar u ocultar la imagen de la camara y las zonas de deteccion utilice:
 b -> para ocular todo
 z -> muestra las zonas de deteccion
 g -> muestra la grilla de deteccion
 v -> muestra la imagen de la webcam
 f -> muestra la imagen de la webcam filtrada
 */
 
import processing.video.*;

//CLASS
Videos dinamoVideos; //creamos el objeto llamado "dinamo" de la clase Videos
Capture camara;
ZoneDetection zonas;

boolean zonasView = false;
boolean filterView = false;
boolean camaraView = false;
boolean gridView = false;

void setup () {
  //size (640, 480); 
  size (displayWidth, displayHeight); 

  camara = new Capture(this, 640, 480, "/dev/video0", 30);// new Capture (this, 640, 480); //Constructor para la captura de la camaraWeb
  zonas = new ZoneDetection (50, 0, 590, camara.height, 4,4, camara);//constructor del detector de zonas
  dinamoVideos = new Videos (5, this); //se escribe la cantidad de videos a ocupar
  
  camara.start();
  zonas.calibrate ();
  
}

void draw () {
  background (120);
  
  if (keyPressed) {
    if ( key == 'c' ) Calibrar ();
    if ( key == 'z' ) zonasView = true;
    if ( key == 'f' ) filterView = true;
    if ( key == 'v' ) camaraView = true;
    if ( key == 'g' ) gridView = true;
    if ( key == 'b' ) {
      zonasView = false;
      filterView = false;
      gridView = false;
      camaraView = false;
    }
  }
  
  zonas.readFilterCam();
  zonas.detectionZones();
  zonas.zonesAnalysis(false, 6000, 2000); // ( boolean par imprimir en consola la Zona activa, 
  //el primer N para determinar la cantidad minima de pixeles que deberán cambiar de color para activar cualquier zona
  //el segundo N determina la cantidad minima de pixeles que deberán cambiar para que una zona activa cambie por otra
  
  if (camaraView) {
    if (camara.available() == true) {
    camara.read();
    image (camara,0,0);
    }
  }
  if (filterView) image (camara,0,0);
  if (zonasView) {
    zonas.dataZone(false); //boolean indica si imprime (+lento) o no los valores
    zonas.viewActiveZone();
  }
  if (gridView) zonas.drawGrid();

  
  dinamoVideos.placeVideos();
  
}

void Calibrar () {
  
  println ("COMENZANDO PROCESO");
  println ("esperando disponibilidad de camara" );
  while (camara.available () == false) {
    print ("." );
  }
  println("Camara disponible!");

  if (camara.available() == true) {
    camara.read();
    camara.filter(THRESHOLD, .5  );
    zonas.calibrate ();
    println ("PROCESO TERMINADO");
    
  }
  else println("camara no disponible. Intente denuevo");
 println (" _ ");
}

  void movieEvent(Movie m) {
  m.read();
  }
  
  
  void mouseClicked() {
   String fileName = "fotos1/screen" + frameCount + ".jpg";
   save(fileName);  
}
