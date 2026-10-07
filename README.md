# Fire evacuation app

Flutter command center for the school fire evacuation system.

## Run

The app uses the Supabase URL and publishable key configured in `lib/main.dart`
by default. Override either with Dart defines when running or building:

```powershell
flutter run `
  --dart-define=SUPABASE_URL=https://your-project.supabase.co `
  --dart-define=SUPABASE_PUBLISHABLE_KEY=your-publishable-key `
  --dart-define=API_BASE_URL=http://127.0.0.1:8000
```

`API_BASE_URL` defaults to `http://127.0.0.1:8000`. For the Android emulator,
use `http://10.0.2.2:8000`; for a physical device, use the computer's reachable
LAN address. The API client calls `/status` for connection health and provides
methods for the sensor, temperature, evacuation-light, and fire endpoints.

## Authentication and database

Sign in with a user created in Supabase Auth. The dashboard reads the campus
tables in the supplied schema. Add a `public.users` profile row with an `id`
matching the Supabase Auth user UUID if you want to show that user's wing/class
details. The app does not authenticate against or read the schema's
`users.password` field.

Configure Supabase permissions/RLS policies so authenticated users can read
dashboard data and perform only the writes their role needs. The campus map is
loaded from `assets/unnamed.png`.
