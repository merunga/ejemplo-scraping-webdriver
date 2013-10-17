Ejemplo de scrapeo con navegación automatizada
=========

Para este ejemplo usaremos los datos de [agro al dia](http://agroaldia.minag.gob.pe/sisin/clients) y scrapearemos la data expuesta por su [formulario de consulta](http://agroaldia.minag.gob.pe/sisin/clients/detalle/location:Siembras,Per%C3%BA/domain:Siembras,Algod%C3%B3n/subject:Siembras,Cosecha/period:Siembras,2000;Siembras,2001;Siembras,2002;Siembras,2003;Siembras,2004;Siembras,2005;Siembras,2006;Siembras,2007;Siembras,2008;Siembras,2009;Siembras,2010;Siembras,2011;Siembras,2012;Siembras,2013/axis:location/flatten:1/prefix:Siembras/write:1/bc:Inicio,index;Cultivos,cadenas.module:Siembras;Algod%C3%B3n,siembrascadenas.Algod%C3%B3n)

> Esta página, por mantener permlinks de sus búsquedas, podría ser scrapeada con un mínimo de necesidad
 de una navegación automatizada, pero para los fines didácticos de este ejemplo no nos basaremos en las
 urls resultantes. Cheque el script `scrap-permlinks.coffee` para ver cómo explotar los permlinks.

Para este ejemplo usaremos javascript como lenguaje, asi para poder ejecutar los scripts, necesitarás
contar con un entorno `nodejs`.
Como driver para la automatización de la navegación, usamos [seleniun](http://www.seleniumhq.org/).
Tu entorno debe cumplir con las siguientes dependencias:
```
npm install webdriver-sync
npm install underscore
npm install coffeescript
```

Luego para comenzar a scrapear, sólo ejecuta en tu consola:
```
coffee scrap.coffee > scraping.log
```
> Ten en cuenta que este script realizará más de 3000 request a la página de origen, que dependiendo de tu conexión puede demorar hasta 5 horas y que tu IP puede ser banneada en el proceso.

Este script creará un archivo `data/data-YYYY-MM-DD-HH-mm.json` con toda la data extraida.

### Post-procesamiento
> Hasta aquí llega el ejercicio de scrapeo, pero como yapita vamos a post-procesar la data para obtener un
 formato más amigable para el consumo

La data scrapeada es guardada en formato `.json` con la misma estructura que se recoge desde la tabla
que la página da como resultado:
```
{
  "cultivo":"Yuca",
  "variedad":"Yuca",
  "criterio":"Rendimiento",
  "provincia":"Ucayali",
  "anio":2013,
  "valor":14122.49
},
{
  "cultivo":"Yuca",
  "variedad":"Yuca",
  "criterio":"Precio",
  "provincia":"Ucayali",
  "anio":2013,
  "valor":0.27
},
```
Pero para disminuir su tamaño vamos a consolidar la data en un registro por año, cuiltivo, variedad, provincia que cuente con todos los criterios. Para eso ejecutamos:
```
coffee process.coffee data/data-YYYY-MM-DD-HH-mm.json
```
Esto generará un archivo `processed-data/data-YYYY-MM-DD-HH-mm.json` con el formato esperado:
```
{
  "anio": 2013,
  "provincia": "Ucayali",
  "cultivo": "Yuca",
  "variedad": "Yuca",
  "cosecha": 3023,
  "produccion": 42692.29,
  "rendimiento": 14122.49,
  "precio": 0.27
}
```
