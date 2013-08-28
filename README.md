Piedras
=======

Interacción webCam+Vidrio+Piedras 

Esta programación esta en proceso, sin embargo ya permite trabajar sobre ella. 
Es importante crear la carpeta /data/  y colocar dentro los videos a ocupar en la programación

Cualquier comentario, pregunta o aporte hacerlo al mail jcruzsm@gmail.com Gracias.

ultima edición: 28/Agosto/2013

LOS PASOS INICIALES

Antes que todo, vamos a abrir Processing y conectar la webCam.

1.- Probar la imagen con el ejemplo "GettingStartedCapture" de la biblioteca de videos: 
Libraries/video/Capture/GettingStartedCapture

Podemos ver el modo de conectarse con una u otra cámara, en el caso que tengas más de una cámara conectada.
Al ejecutar el programa podemos ver en la consola el nombre de las cámaras conectadas
en mi caso es:  /dev/video0.
De modo que puedo conectarme directamente con este nombre cuando llamamos al constructor de la clase Capture:
cam = new Capture(this, 640, 480, "/dev/video0", 30);

2.-Con la programación de prueba ajustamos la posición y el enfoque de la cámara

3.- Con la camara correctamente ubicada y enfoncada, se fija a la base desde donde capatará la imagen de la superficie
    Ahora abrimos la programación de nuestra aplicación.

4.- Ocupamos el nombre de la cámara que ya descubrimos para indicarle a nuestra porgramación qué cámara ocuparemos, y hechamos a correr el programa

void setup () {
  //size (640, 480); 
  size (displayWidth, displayHeight); 

  camara = new Capture(this, 640, 480, "/dev/video0", 30);// new Capture (this, 640, 480); //Constructor para la captura de la camaraWeb
  zonas = new ZoneDetection (50, 50, 590, 430, 4,4, camara);//constructor del detector de zonas
  dinamoVideos = new Videos (5, this); //se escribe la cantidad de videos a ocupar
  
  camara.start();
  zonas.calibrate ();
  
}

5.- presionamos las teclas 
 b -> para ocular todo
 z -> muestra las zonas de deteccion
 g -> muestra la grilla de deteccion
 v -> muestra la imagen de la webcam
 f -> muestra la imagen de la webcam filtrada

Con la imagen que nos entrega la programación definimos en el constructor de la clase "ZoneDetection" 
cuál será la zona donde nos concentraremos para detectar el movimiento de las piedras

zonas = new ZoneDetection (50, 50, 590, 430, 4,4, camara);

5.- ajustamos el filtro de la imagen THRESHOLD, entre 0 y 1, cargado mas cerca de 1

6.- Ajustamos los valores de la deteccion
zonas.zonesAnalysis(false, 2000, 1000);
zonas.zonesAnalysis(false, 4000, 2000);

Es posible que se necesite realizar una nueva calibración cada cierto tiempo, o cada vez que no hay video seleccionado.
