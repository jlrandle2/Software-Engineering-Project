import requests

BASE = "http://127.0.0.1:8000"

# -------------------------
# STEP 1: GET ALL STATIONS
# -------------------------
def get_station_map():
    res = requests.get(f"{BASE}/stations")
    data = res.json()

    # map: "Station Name" → station_id
    return {s["station_name"]: s["station_id"] for s in data}


# -------------------------
# STEP 2: CREATE ROUTE
# -------------------------
def create_route(route_name, station_names, station_map):
    stops = []

    for i, name in enumerate(station_names):
        if name not in station_map:
            print(f"❌ Missing station: {name}")
            return

        stops.append({
            "station_id": station_map[name],
            "stop_sequence": i + 1
        })

    res = requests.post(f"{BASE}/routes", json={
        "route_name": route_name,
        "direction": "northbound",
        "stops": stops
    })

    print(f"\n🚆 {route_name}:")
    print(res.status_code)
    print(res.text)


# -------------------------
# STEP 3: DEFINE ALL LINES
# -------------------------

RED_LINE = [
    "North Springs",
    "Sandy Springs",
    "Dunwoody",
    "Medical Center",
    "Buckhead",
    "Lenox",
    "Lindbergh Center",
    "Arts Center",
    "Midtown",
    "North Avenue",
    "Civic Center",
    "Peachtree Center",
    "Five Points",
    "Garnett",
    "West End",
    "Oakland City",
    "Lakewood/Ft. McPherson",
    "East Point",
    "College Park",
    "Airport"
]

GOLD_LINE = [
    "Doraville",
    "Chamblee",
    "Brookhaven/Oglethorpe",
    "Lenox",
    "Lindbergh Center",
    "Arts Center",
    "Midtown",
    "North Avenue",
    "Civic Center",
    "Peachtree Center",
    "Five Points",
    "Garnett",
    "West End",
    "Oakland City",
    "Lakewood/Ft. McPherson",
    "East Point",
    "College Park",
    "Airport"
]

BLUE_LINE = [
    "Hamilton E. Holmes",
    "West Lake",
    "Ashby",
    "Vine City",
    "GWCC/CNN Center",
    "Peachtree Center",
    "Five Points",
    "Georgia State",
    "King Memorial",
    "Inman Park/Reynoldstown",
    "Edgewood/Candler Park",
    "East Lake",
    "Decatur",
    "Avondale",
    "Kensington",
    "Indian Creek"
]

GREEN_LINE = [
    "Bankhead",
    "Ashby",
    "Vine City",
    "GWCC/CNN Center",
    "Peachtree Center",
    "Five Points",
    "Georgia State",
    "King Memorial",
    "Inman Park/Reynoldstown",
    "Edgewood/Candler Park"
]


# -------------------------
# RUN EVERYTHING
# -------------------------
if __name__ == "__main__":
    station_map = get_station_map()

    create_route("Red Line", RED_LINE, station_map)
    create_route("Gold Line", GOLD_LINE, station_map)
    create_route("Blue Line", BLUE_LINE, station_map)
    create_route("Green Line", GREEN_LINE, station_map)

    print("\n✅ Done populating all routes.")