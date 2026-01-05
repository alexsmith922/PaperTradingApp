# Space Object Catalog Web App - Architecture Plan

## Overview

A web application that catalogs celestial objects viewable through telescopes, providing personalized difficulty ratings based on the user's location, current weather conditions, and light pollution levels.

---

## Core Features

1. **Space Object Catalog** - Searchable database of celestial objects (stars, planets, galaxies, nebulae, comets, etc.)
2. **Dynamic Difficulty Rating** - Real-time difficulty scores based on viewing conditions
3. **Location-Based Filtering** - Objects visible from user's position at current time
4. **Weather Integration** - Cloud cover, humidity, atmospheric conditions
5. **Light Pollution Mapping** - Bortle scale integration for sky darkness assessment

---

## System Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              CLIENT LAYER                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐              │
│  │   Web App       │  │   PWA Support   │  │  Mobile Web     │              │
│  │   (React/Next)  │  │   (Offline)     │  │  (Responsive)   │              │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘              │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                              API GATEWAY                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│  • Rate Limiting  • Authentication  • Request Routing  • Caching            │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                    ┌───────────────┼───────────────┐
                    ▼               ▼               ▼
┌───────────────────────┐ ┌─────────────────┐ ┌─────────────────────────────┐
│   CATALOG SERVICE     │ │ VISIBILITY SVC  │ │   CONDITIONS SERVICE        │
├───────────────────────┤ ├─────────────────┤ ├─────────────────────────────┤
│ • Object Database     │ │ • Sky Position  │ │ • Weather API Integration   │
│ • Search/Filter       │ │ • Rise/Set Times│ │ • Light Pollution Data      │
│ • Object Metadata     │ │ • Altitude/Azim │ │ • Difficulty Calculator     │
│ • Images/Descriptions │ │ • Best Viewing  │ │ • Forecast Integration      │
└───────────────────────┘ └─────────────────┘ └─────────────────────────────┘
          │                       │                       │
          └───────────────────────┼───────────────────────┘
                                  ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                           DATA LAYER                                         │
├─────────────────────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐              │
│  │   PostgreSQL    │  │     Redis       │  │   S3/CDN        │              │
│  │   (Primary DB)  │  │   (Cache)       │  │   (Images)      │              │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘              │
└─────────────────────────────────────────────────────────────────────────────┘
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                        EXTERNAL INTEGRATIONS                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐              │
│  │  Weather APIs   │  │  Light Pollution│  │  Astronomy DBs  │              │
│  │  (OpenWeather)  │  │  (Bortle Data)  │  │  (SIMBAD/NASA)  │              │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Technology Stack

### Frontend
| Component | Technology | Rationale |
|-----------|------------|-----------|
| Framework | **Next.js 14** | SSR for SEO, App Router, React Server Components |
| UI Library | **Tailwind CSS + shadcn/ui** | Rapid development, consistent design |
| State Management | **Zustand** | Lightweight, simple API |
| Maps | **Mapbox GL** or **Leaflet** | Interactive sky maps and location picker |
| 3D Sky View | **Three.js** or **Stellarium Web** | Optional interactive star chart |

### Backend
| Component | Technology | Rationale |
|-----------|------------|-----------|
| Runtime | **Node.js** or **Python (FastAPI)** | Rich astronomy libraries in Python |
| API Style | **REST + GraphQL** | REST for simple queries, GraphQL for complex filtering |
| Authentication | **Auth.js (NextAuth)** | Easy OAuth, session management |
| Background Jobs | **BullMQ** or **Celery** | Weather data sync, difficulty recalculation |

### Database
| Component | Technology | Rationale |
|-----------|------------|-----------|
| Primary DB | **PostgreSQL + PostGIS** | Spatial queries for location-based filtering |
| Cache | **Redis** | Frequently accessed objects, session data |
| Search | **Elasticsearch** or **Meilisearch** | Full-text search across objects |

### Infrastructure
| Component | Technology | Rationale |
|-----------|------------|-----------|
| Hosting | **Vercel** (frontend) + **Railway/Fly.io** (backend) | Easy deployment, global edge |
| CDN | **Cloudflare** | Image caching, DDoS protection |
| Monitoring | **Sentry + Vercel Analytics** | Error tracking, performance |

---

## Data Models

### SpaceObject
```
{
  id: UUID
  name: string
  common_names: string[]           // Alternative names
  type: enum [STAR, PLANET, GALAXY, NEBULA, CLUSTER, COMET, ASTEROID, SATELLITE]
  catalog_ids: {                   // Cross-references
    messier: string | null         // M31
    ngc: string | null             // NGC 224
    ic: string | null              // IC 1613
    hd: string | null              // HD numbers for stars
  }
  coordinates: {
    ra: float                      // Right Ascension (degrees)
    dec: float                     // Declination (degrees)
    distance_ly: float | null      // Distance in light years
  }
  physical: {
    magnitude: float               // Apparent magnitude
    size_arcmin: float | null      // Angular size
    constellation: string
  }
  viewing: {
    min_aperture_mm: int           // Minimum telescope aperture
    best_season: string[]          // Best months to view
    base_difficulty: int           // 1-10 inherent difficulty
  }
  media: {
    thumbnail_url: string
    images: string[]
    description: text
  }
  metadata: {
    created_at: timestamp
    updated_at: timestamp
  }
}
```

### UserLocation
```
{
  id: UUID
  user_id: UUID | null             // Optional for anonymous users
  latitude: float
  longitude: float
  elevation_m: float
  timezone: string
  bortle_class: int                // 1-9 light pollution scale
  created_at: timestamp
}
```

### ViewingConditions
```
{
  id: UUID
  location_id: UUID
  timestamp: timestamp
  weather: {
    cloud_cover_pct: int           // 0-100
    humidity_pct: int
    temperature_c: float
    wind_speed_kph: float
    visibility_km: float
    precipitation: boolean
  }
  astronomical: {
    moon_phase: float              // 0-1 (0=new, 1=full)
    moon_altitude: float           // Degrees above horizon
    sun_altitude: float            // For twilight calculation
    seeing_arcsec: float           // Atmospheric seeing
  }
  calculated: {
    transparency: int              // 1-5 scale
    overall_score: int             // 1-100 composite
  }
}
```

### DifficultyRating (Computed)
```
{
  object_id: UUID
  location_id: UUID
  conditions_id: UUID
  timestamp: timestamp
  factors: {
    altitude_score: int            // How high in sky (higher = easier)
    magnitude_score: int           // Brightness adjusted for conditions
    light_pollution_score: int     // Bortle impact
    weather_score: int             // Cloud cover, transparency
    moon_interference: int         // Moon proximity/phase impact
    equipment_match: int           // User's equipment vs required
  }
  final_difficulty: int            // 1-10 (1=easy, 10=expert)
  visibility_window: {
    rises_at: timestamp
    sets_at: timestamp
    best_time: timestamp
    max_altitude: float
  }
  recommendation: string           // "Excellent tonight" / "Wait for new moon"
}
```

---

## Difficulty Calculation Algorithm

```
DIFFICULTY = weighted_average(
  base_difficulty × 0.20,          // Inherent object difficulty
  magnitude_factor × 0.25,         // Adjusted for conditions
  altitude_factor × 0.15,          // Higher = easier
  light_pollution × 0.20,          // Bortle scale impact
  weather_factor × 0.15,           // Cloud cover, transparency
  moon_factor × 0.05               // Moon interference
)

Adjustments:
- If object below horizon: IMPOSSIBLE
- If sun altitude > -12°: Add +3 difficulty (twilight)
- If moon within 30° and >50% illuminated: Add +1-2 difficulty
- If cloud cover > 80%: POOR CONDITIONS warning
```

---

## External API Integrations

### Weather Data
| Provider | Data | Cost |
|----------|------|------|
| **OpenWeatherMap** | Current + forecast, cloud cover | Free tier: 1000 calls/day |
| **Visual Crossing** | Historical + forecast | Free tier: 1000 calls/day |
| **Tomorrow.io** | Minute-by-minute clouds | Free tier: 500 calls/day |

### Astronomical Data
| Provider | Data | Cost |
|----------|------|------|
| **SIMBAD** (CDS) | Object catalog, cross-references | Free |
| **NASA Horizons** | Ephemeris for solar system objects | Free |
| **Stellarium Web** | Star charts, object positions | Free/Open source |

### Light Pollution
| Provider | Data | Cost |
|----------|------|------|
| **Light Pollution Map** | Global Bortle scale data | Free (static dataset) |
| **VIIRS satellite data** | Night light measurements | Free (NASA) |

---

## Key User Flows

### 1. Discovery Flow
```
User opens app
  → Geolocation prompt (or manual location entry)
  → Fetch current conditions (weather + light pollution)
  → Calculate visible objects for tonight
  → Display sorted by difficulty (easy first) or by type
  → User taps object → Detail view with viewing tips
```

### 2. Planning Flow
```
User selects future date/time
  → Calculate predicted conditions (weather forecast + moon phase)
  → Show what will be visible
  → Highlight "best bets" for that night
  → Optional: Set reminder notification
```

### 3. Equipment Matching (Future)
```
User enters their equipment (telescope aperture, mount type)
  → Filter objects achievable with their setup
  → Difficulty adjusted for their specific equipment
```

---

## MVP Scope (Phase 1)

### Included
- [ ] Core object catalog (Messier objects + bright planets)
- [ ] Location detection + manual entry
- [ ] Current weather integration
- [ ] Light pollution lookup (static Bortle data)
- [ ] Basic difficulty calculation
- [ ] Object search and filtering
- [ ] Object detail pages with images
- [ ] "Tonight's best" recommendations

### Deferred to Phase 2
- User accounts and saved locations
- Equipment profiles
- Observation logging
- Social features (shared observations)
- Push notifications
- Offline PWA support
- Advanced planning (multi-night)

---

## API Endpoints (Draft)

```
GET  /api/objects                    # List all objects (paginated)
GET  /api/objects/:id                # Single object details
GET  /api/objects/search?q=          # Search objects

GET  /api/visible                    # Objects visible now at location
     ?lat=&lon=                      # Required: coordinates
     ?date=                          # Optional: future date
     ?difficulty_max=                # Optional: filter by difficulty

GET  /api/conditions                 # Current viewing conditions
     ?lat=&lon=                      # Required: coordinates

GET  /api/objects/:id/difficulty     # Difficulty for specific object
     ?lat=&lon=                      # Required: coordinates

GET  /api/light-pollution            # Bortle class for location
     ?lat=&lon=
```

---

## Open Questions for Discussion

1. **User Accounts**: Should we require accounts, or allow anonymous usage with optional sign-up?

2. **Data Source**: Start with Messier catalog only (~110 objects) or include NGC (~8000 objects)?

3. **Real-time vs Cached**: How fresh should weather data be? (Every 15 min? 1 hour?)

4. **Mobile Priority**: Build as responsive web first, or consider React Native for native apps later?

5. **Equipment Complexity**: Include telescope/eyepiece matching in MVP or defer?

6. **Monetization**: Free with ads? Freemium? One-time purchase?

---

## Next Steps

1. **Validate architecture** - Review this plan together
2. **Answer open questions** - Finalize scope decisions
3. **Design UI mockups** - Wireframe key screens
4. **Set up project** - Initialize repo, CI/CD, base infrastructure
5. **Build MVP** - Implement Phase 1 features

