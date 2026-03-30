import requests

BASE = "http://127.0.0.1:8000"

def get_station_map():
    res = requests.get(f"{BASE}/stations")
    data = res.json()
    return {s["station_name"]: s["station_id"] for s in data}


def create_route(route_name, station_names, station_map, direction):
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
        "direction": direction,
        "stops": stops
    })

    print(f"\n🚆 {route_name} ({direction}):")
    print(res.status_code)
    print(res.text)


# -------------------------
# DATA
# -------------------------

RED_LINE = [
    "North Springs","Sandy Springs","Dunwoody","Medical Center",
    "Buckhead","Lenox","Lindbergh Center","Arts Center","Midtown",
    "North Avenue","Civic Center","Peachtree Center","Five Points",
    "Garnett","West End","Oakland City","Lakewood/Ft. McPherson",
    "East Point","College Park","Airport"
]

GOLD_LINE = [
    "Doraville","Chamblee","Brookhaven/Oglethorpe","Lenox",
    "Lindbergh Center","Arts Center","Midtown","North Avenue",
    "Civic Center","Peachtree Center","Five Points","Garnett",
    "West End","Oakland City","Lakewood/Ft. McPherson",
    "East Point","College Park","Airport"
]

BLUE_LINE = [
    "Hamilton E. Holmes","West Lake","Ashby","Vine City",
    "GWCC/CNN Center","Peachtree Center","Five Points",
    "Georgia State","King Memorial","Inman Park/Reynoldstown",
    "Edgewood/Candler Park","East Lake","Decatur",
    "Avondale","Kensington","Indian Creek"
]

GREEN_LINE = [
    "Bankhead","Ashby","Vine City","GWCC/CNN Center",
    "Peachtree Center","Five Points","Georgia State",
    "King Memorial","Inman Park/Reynoldstown",
    "Edgewood/Candler Park"
]


# -------------------------
# RUN
# -------------------------

if __name__ == "__main__":
    station_map = get_station_map()

    # RED
    create_route("Red Line", RED_LINE, station_map, "southbound")
    create_route("Red Line", list(reversed(RED_LINE)), station_map, "northbound")

    # GOLD
    create_route("Gold Line", GOLD_LINE, station_map, "southbound")
    create_route("Gold Line", list(reversed(GOLD_LINE)), station_map, "northbound")

    # BLUE
    create_route("Blue Line", BLUE_LINE, station_map, "eastbound")
    create_route("Blue Line", list(reversed(BLUE_LINE)), station_map, "westbound")

    # GREEN
    create_route("Green Line", GREEN_LINE, station_map, "eastbound")
    create_route("Green Line", list(reversed(GREEN_LINE)), station_map, "westbound")

    print("\n✅ Done populating all routes.")