const express = require('express')
const cors = require('cors')

const app = express()

app.use(cors())
app.use(express.json())

const PORT = 5000


// Start trip tracking
app.post('/trackTrip', (req, res) => {

  const { route, start_station, destination } = req.body

  console.log("Trip started:")
  console.log(route, start_station, destination)

  res.json({
    status: "Trip tracking started"
  })

})


// Report delay / incident
app.post('/reportAlert', (req, res) => {

  const { route, station, description } = req.body

  console.log("Alert received:")
  console.log(route, station, description)

  res.json({
    status: "Alert stored successfully"
  })

})


app.listen(PORT, () => {
  console.log(`TransitSense backend running on port ${PORT}`)
})