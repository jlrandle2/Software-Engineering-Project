import requests

BASE_URL = "http://127.0.0.1:8000"

# approximate coordinates (good enough for project/demo)
stations = [
    # RED LINE
    ("North Springs", 33.9446, -84.3573),
    ("Sandy Springs", 33.9301, -84.3526),
    ("Dunwoody", 33.9213, -84.3444),
    ("Medical Center", 33.9107, -84.3513),
    ("Buckhead", 33.8484, -84.3670),
    ("Lenox", 33.8453, -84.3567),
    ("Lindbergh Center", 33.8230, -84.3696),
    ("Arts Center", 33.7894, -84.3875),
    ("Midtown", 33.7811, -84.3865),
    ("North Avenue", 33.7717, -84.3872),
    ("Civic Center", 33.7665, -84.3877),
    ("Peachtree Center", 33.7580, -84.3876),
    ("Five Points", 33.7537, -84.3915),
    ("Garnett", 33.7486, -84.3955),
    ("West End", 33.7358, -84.4133),
    ("Oakland City", 33.7174, -84.4250),
    ("Lakewood/Ft. McPherson", 33.7000, -84.4290),
    ("East Point", 33.6777, -84.4408),
    ("College Park", 33.6517, -84.4488),
    ("Airport", 33.6407, -84.4462),

    # GOLD LINE EXTENSION
    ("Brookhaven/Oglethorpe", 33.8603, -84.3396),
    ("Chamblee", 33.8871, -84.3054),
    ("Doraville", 33.9026, -84.2800),

    # BLUE LINE
    ("Hamilton E. Holmes", 33.7546, -84.4694),
    ("West Lake", 33.7533, -84.4467),
    ("Ashby", 33.7563, -84.4174),
    ("Vine City", 33.7567, -84.4043),
    ("GWCC/CNN Center", 33.7560, -84.3973),
    ("Georgia State", 33.7505, -84.3867),
    ("King Memorial", 33.7477, -84.3754),
    ("Inman Park/Reynoldstown", 33.7572, -84.3526),
    ("Edgewood/Candler Park", 33.7613, -84.3392),
    ("East Lake", 33.7652, -84.3127),
    ("Decatur", 33.7745, -84.2963),
    ("Avondale", 33.7753, -84.2806),
    ("Kensington", 33.7726, -84.2510),
    ("Indian Creek", 33.7697, -84.2295),

    # GREEN LINE
    ("Bankhead", 33.7727, -84.4285),
]

def create_station(name, lat, lon):
    res = requests.post(
        f"{BASE_URL}/stations",
        json={
            "station_name": name,
            "latitude": lat,
            "longitude": lon,
            "status": "active"
        }
    )

    if res.status_code == 200:
        print(f"✅ Created: {name}")
    else:
        print(f"⚠️ Skipped/Failed: {name} → {res.text}")


if __name__ == "__main__":
    print("Populating stations...\n")

    for name, lat, lon in stations:
        create_station(name, lat, lon)

    print("\nDone.")