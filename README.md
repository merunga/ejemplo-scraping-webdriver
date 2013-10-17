Ejemplo de scrapeo con navegación automatizada
=========

Para este ejemplo usaremos los datos de [agro al dia](http://agroaldia.minag.gob.pe/sisin/clients) y scrapearemos la data expuesta por su [formulario de consulta](http://agroaldia.minag.gob.pe/sisin/clients/detalle/location:Siembras,Per%C3%BA/domain:Siembras,Algod%C3%B3n/subject:Siembras,Cosecha/period:Siembras,2000;Siembras,2001;Siembras,2002;Siembras,2003;Siembras,2004;Siembras,2005;Siembras,2006;Siembras,2007;Siembras,2008;Siembras,2009;Siembras,2010;Siembras,2011;Siembras,2012;Siembras,2013/axis:location/flatten:1/prefix:Siembras/write:1/bc:Inicio,index;Cultivos,cadenas.module:Siembras;Algod%C3%B3n,siembrascadenas.Algod%C3%B3n)

> Esta página, por mantener permlinks de sus búsquedas, podría ser scrapeada sin la necesidad bloqueante
 de una navegación automatizada, pero para los fines didácticos de este ejemplo no nos basaremos en las
 urls resultantes. Chequea el script `scrap-permlinks.coffee` para ver cómo usar webdriver para explotar
 los permlinks.

Para este ejemplo usaremos `coffeescript` como lenguaje, asi para poder ejecutar los scripts, necesitarás
contar con un entorno `nodejs` además de Firefox instalado (este ejemplo en particular no funciona con Chrome,
está relacionado con [este bug](http://code.google.com/p/chromedriver/issues/detail?id=35), que supuestamente
ya debería estar resuelto).
Como driver para la automatización de la navegación, usamos [seleniun](http://www.seleniumhq.org/).
Tu instalación de `node` debe cumplir con las siguientes dependencias:
```
npm install webdriver-sync
npm install underscore
npm install coffeescript
```
> En este caso he usado el paquete `webdriver-sync` en lugar del oficial `selenium-webdriver` porque mantiene
 una API mucho más parecida a los bindings con otros lenguajes. Es decir que el código de este script es fácilmente
 traducible a cualquier lenguaje que cuente con bindings para selenium, por ejemplo `ruby`, `python`, `java`, `perl`, `php` o `C#`

Luego para comenzar a scrapear, sólo ejecuta en tu consola:
```
coffee scrap.coffee > scraping.log
```
> Ten en cuenta que este script realizará más de 3000 request a la página de origen, que dependiendo de tu conexión puede demorar hasta 5 horas y que tu IP puede ser banneada en el proceso

Este script creará un archivo `data/data-YYYY-MM-DD-HH-mm.json` con toda la data extraida.
Para evitarles la chamba a todos, en el repositorio ya hay una carpeta `data` con el [resultado de una corrida completa](https://raw.github.com/merunga/ejemplo-scraping-webdriver/master/data/data-2013-10-13-23-33.json)
completa del script (5MB).

Si quieres entender y adaptar este robotito, chequea el archivo `scrap.coffee` que tiene varios comentarios.

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
En la carpeta `processed-data` encontrarás el [archivo resultante](https://raw.github.com/merunga/ejemplo-scraping-webdriver/master/processed-data/data-2013-10-13-23-33.json) de todo el proceso de scrapeo y post-procesamiento (2MB).