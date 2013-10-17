console.log "Archivo a procesar: #{process.argv[2]}"

# dataFile = require "./#{process.argv[2]}"
# data = JSON.parse dataFile

fs = require("fs")
_ = require('underscore')._

file = __dirname + "/#{process.argv[2]}"
unprocessedData = null
data = {}
finalData = []

fs.readFile file, "utf8", (err, readData) ->
  if err
    console.log "Error: " + err
    return

  unprocessedData = JSON.parse readData

  _.each unprocessedData, (row) ->
    data[row.anio] = {} unless data[row.anio]
    data[row.anio][row.departamento] = {} unless data[row.anio][row.departamento]
    unless data[row.anio][row.departamento][row.cultivo]
      data[row.anio][row.departamento][row.cultivo] = {}
    unless data[row.anio][row.departamento][row.cultivo][row.variedad]
      data[row.anio][row.departamento][row.cultivo][row.variedad] = {}

    data[row.anio][row.departamento][row.cultivo][row.variedad][row.criterio] = row.valor

  for anio, departamentos of data
    for departamento, cultivos of departamentos
      for cultivo, variedades of cultivos
        for variedad, criterios of variedades
          row =
            anio: parseInt anio
            departamento: departamento
            cultivo: cultivo
            variedad: variedad
          for criterio, valor of criterios
            row[ criterio.toLowerCase() ] = valor
          finalData.push row

  console.log "Procesando #{finalData.length} registros"
  outFileName = "processed-#{process.argv[2]}"
  fs.writeFile outFileName, JSON.stringify( finalData, null, 2 ), (err) ->
    if err
      console.log err
    else
      console.log "Data procesada: #{outFileName}"
