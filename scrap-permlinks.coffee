DEVEL = false

fs = require('fs');
webdriver = require("webdriver-sync")
By = webdriver.By
_ = require('underscore')._
moment = require('moment')

driver = new webdriver.ChromeDriver

root = "Siembras"
cultivoStr =  (categoria, variedad) -> "#{root},#{categoria},#{variedad}"
endpoint = ( departamento, cultivo, variedad, criterio) ->
  departamento = "#{root},Per%C3%BA,#{departamento}"
  cultivo = cultivoStr cultivo, variedad
  criterio = "#{root},#{criterio}"
  period = ''
  _([2000..2013]).each (year)->
    period += "#{root},#{year};"
  period = period.slice(0,-1) #quito ultimo ';'
  baseUrl = "http://agroaldia.minag.gob.pe/sisin/clients/detalle/"
  unless DEVEL
    return "#{baseUrl}location:#{departamento}/subject:#{criterio}/domain:#{cultivo}/period:#{period}/axis:/flatten:1/prefix:#{root}/write:1/bc:"
  return "file:///home/merunga/escuelab/agro-peru/static-source/static.html"

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

dataFileName = "data/data-#{moment().format('YYYY-MM-DD-HH-mm')}.json"
console.log "Data file: #{dataFileName}\n"
dataFile = fs.openSync dataFileName, "w"
urlCount = 0

getRow = (departamento = "Amazonas", cultivo = "Ajo", variedad = "Ajo", criterio = "Produccion") ->
  url = endpoint departamento, cultivo, variedad, criterio
  urlCount++
  console.log "[#{moment().format('YYYY-MM-DD HH:mm:ss')}] begin GET: #{url}"

  driver.get url
  try
    driver.findElement( By.id "ToolTables_0_4" ).click()
    _( driver.findElements By.xpath '//table[@class="display"]//tr' ).each (tr) =>
      row =
        "cultivo": cultivo
        "variedad": variedad
        "criterio": criterio
        "departamento": departamento

      hayData = false
      _( tr.findElements( By.tagName 'td' ) ).each (td, idx) ->
        hayData = true
        text = td.getText()
        switch idx
          when 1 then row["anio"] = parseInt text
          when 3 then row["valor"] = parseFloat text

      if hayData
        fs.writeSync dataFile, "#{JSON.stringify row},\n"
  catch e
    console.log '** WARNING **: No hay data'

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

if DEVEL
  getRow()
else
  getAllData()

driver.quit()
