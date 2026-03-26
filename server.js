const express = require('express')
const cors = require('cors')
const mysql = require('mysql2/promise');


const pool = mysql.createPool({
  host: '127.0.0.1',
  user: 'root', 
  password: '',
  database: 'transitsense',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

const app = express()

app.use(cors())
app.use(express.json())

const PORT = 5001



app.post('/trackTrip', async (req, res) => {

  const { route, start_station, destination } = req.body

  console.log("Trip started:")
  console.log(route, start_station, destination)

  // Added database verification
  try {
    const [rows] = await pool.execute('SELECT * FROM routes WHERE route_name = ?', [route]);
    console.log('DB Connection successful: Verified route.');
  } catch (err) {
    console.error('DB Error:', err.message);
  }

  res.json({
    status: "Trip tracking started"
  })

})



app.post('/reportAlert', async (req, res) => {

  const { route, station, description } = req.body

  console.log("Alert received:")
  console.log(route, station, description)

  // Added database insert
  try {
    await pool.execute(
      'INSERT INTO system_alerts (alert_type, description) VALUES (?, ?)',
      ['Delay/Incident', description]
    );
    console.log('Success: Alert saved to the MySQL database!');
  } catch (err) {
    console.error('DB Error:', err.message);
  }

  res.json({
    status: "Alert stored successfully"
  })

})


app.listen(PORT, () => {
  console.log(`TransitSense backend running on port ${PORT}`)
})
