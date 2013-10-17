DEVEL = false

# dependencias
fs = require('fs');
driverOrig = 
webdriver = require("webdriver-sync")
By = webdriver.By
Key = require('selenium-webdriver').Key
_ = require('underscore')._
moment = require('moment')

driver = new webdriver.FirefoxDriver

departamentos = [
  "Amazonas", "Ancash", "Apurímac", "Arequipa", "Ayacucho", "Cajamarca",
  "Cusco", "Huancavelica", "Huánuco", "Ica", "Junín", "La Libertad",
  "Lambayeque", "Lima", "Loreto", "Madre de Dios", "Moquegua", "Pasco",
  "Piura", "Puno", "San Martín", "Tacna", "Tumbes", "Ucayali"
]
  
cultivos = [
  {categoria: "Ajo", variedades: ["Ajo"]},
  {categoria: "Algodón", variedades: ["Algodón Rama"]},
  {categoria: "Arroz", variedades: ["Arroz Cascara"]},
  {categoria: "Cacao", variedades: ["Cacao"]},
  {categoria: "Café", variedades: ["Café"]},
  {categoria: "Caña de Azúcar", variedades: ["Caña de Azúcar"]},
  {categoria: "Cebolla", variedades: ["Cebolla"]},
  {categoria: "Limón", variedades: ["Limón"]},
  {categoria: "Mandarina y Tangelo", variedades: ["Mandarina y Tangelo"]},
  {categoria: "Naranja", variedades: ["Naranja"]},
  {categoria: "Espárrago", variedades: ["Espárrago"]},
  {categoria: "Maíz Amarillo Duro", variedades: ["Maíz Amarillo Duro"]},
  {categoria: "Maíz Amilaceo", variedades: [
    "Maíz Amilaceo", "Maíz Choclo"
  ]},
  {categoria: "Mango", variedades: ["Mango"]},
  {categoria: "Arverja", variedades: [
    "Arverja Grano Seco","Arverja Grano Verde"
  ]},
  {categoria: "Frijol", variedades: [
    "Frijol Castilla","Frijol de Palo","Frijol Grano Seco","Frijol Loctao","Frijol"
  ]},
  {categoria: "Lenteja", variedades: ["Lenteja"]},
  {categoria: "Olivo", variedades: ["Aceituna"]},
  {categoria: "Palma Aceitera", variedades: ["Palma Aceitera"]},
  {categoria: "Palta", variedades: ["Palta"]},
  {categoria: "Papa", variedades: ["Papa"]},
  {categoria: "Platano", variedades: ["Platano"]},
  {categoria: "Quinua", variedades: ["Quinua"]},
  {categoria: "Sorgo", variedades: ["Sorgo"]},
  {categoria: "Soya", variedades: ["Soya"]},
  {categoria: "Trigo", variedades: ["Trigo"]},
  {categoria: "Vid", variedades: ["Uva"]},
  {categoria: "Yuca", variedades: ["Yuca"]}
]

criterios = ["Cosecha","Produccion","Rendimiento","Precio"]

# archivo de salida
dataFileName = "data/data-#{moment().format('YYYY-MM-DD-HH-mm')}.json"
console.log "Data file: #{dataFileName}\n"
dataFile = fs.openSync dataFileName, "w"
urlCount = 0

cultivoStr =  (categoria, variedad) -> "Siembras,#{categoria},#{variedad}"

getRow = (departamento = "Perú", cultivo = "Ajo", variedad = "Ajo", criterio = "Produccion") ->
  urlCount++
  console.log "[#{moment().format('YYYY-MM-DD HH:mm:ss')}] begin GET"

  # seleccionamos departamento
  driver.findElement( By.id 'ClientsUbicación' ) \
    .findElement( By.xpath "//option[text()='#{departamento}']" ).click()

  # seleccionamos cultivo
  cultivoVal = cultivoStr cultivo, variedad
  driver.findElement( By.id 'ClientsCultivo' ) \
    .findElement( By.cssSelector "option[value='#{cultivoVal}']" ).click()

  #seleccionamos criterio
  driver.findElement( By.id 'ClientsCriterio' ) \
    .findElement( By.xpath "//option[text()='#{criterio}']" ).click()

  # submit del formulario
  driver.findElement( By.cssSelector "input[value='Consultar']" ).click()
  
  try
    # click al boton print para obtener la tabla sin paginar
    driver.findElement( By.id "ToolTables_0_4" ).click()
    # para cada columa de la tabla
    _( driver.findElements By.xpath '//table[@class="display"]//tr' ).each (tr) =>
      row =
        "cultivo": cultivo
        "variedad": variedad
        "criterio": criterio
      hayData = false
      _( tr.findElements( By.tagName 'td' ) ).each (td, idx) ->
        hayData = true
        text = td.getText()
        switch idx
          when 1 then row["anio"] = parseInt text
          when 2 then row['departamento'] = text
          when 3 then row["valor"] = parseFloat text

      if hayData
        fs.writeSync dataFile, "#{JSON.stringify row},\n"
  catch e
    console.log '** WARNING **: No hay data'

  driver.findElement( By.cssSelector "table.display" ).sendKeys Key.ESCAPE     
  console.log "[#{moment().format('YYYY-MM-DD HH:mm:ss')}] end GET #{urlCount}\n"

getAllData = ->
    fs.writeSync dataFile, "[ \n"
    _.each cultivos, (cultivo) ->
      _.each departamentos, (departamento) ->
        categoria = cultivo.categoria
        _.each cultivo.variedades, (variedad) ->
          _.each criterios, (criterio) ->
            getRow departamento, categoria, variedad, criterio
    fs.writeSync dataFile, " ]\n"

unless DEVEL
  url = "http://agroaldia.minag.gob.pe/sisin/clients/detalle/location:Siembras,Per%C3%BA/" \
    +"domain:Siembras,Algod%C3%B3n/subject:Siembras,Cosecha/period:Siembras,2000;Siembras,2001;" \
    +"Siembras,2002;Siembras,2003;Siembras,2004;Siembras,2005;Siembras,2006;Siembras,2007;Siembras" \
    +",2008;Siembras,2009;Siembras,2010;Siembras,2011;Siembras,2012;Siembras,2013/axis:location/" \
    +"flatten:1/prefix:Siembras/write:1/bc:Inicio,index;Cultivos,cadenas.module:Siembras;Algod%C3%B3n" \
    +",siembrascadenas.Algod%C3%B3n"
else
  url = "file:///home/merunga/escuelab/agro-peru/static-source/static.html"

driver.get url
getAllData()

driver.quit()
