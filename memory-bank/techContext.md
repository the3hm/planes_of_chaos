# ExVenture Technical Context

## Development Environment

### Requirements
- Elixir 1.14+
- Erlang/OTP 25+
- Node.js 18+
- PostgreSQL 14+
- Docker (optional, for containerized development)

### Local Setup
```bash
# Clone repository
git clone <repository>

# Install Elixir dependencies
mix deps.get
mix deps.compile

# Install Node.js dependencies
cd assets && yarn install

# Setup database
mix ecto.setup

# Start development server
mix phx.server
```

## Core Technologies

### Backend
1. **Elixir/Erlang**
   - Phoenix Framework
   - Ecto for database
   - Phoenix LiveView
   - Phoenix PubSub
   - GenServer/Supervision Trees

2. **PostgreSQL**
   - Primary data store
   - JSONB for flexible data
   - Full-text search capabilities

### Frontend
1. **React**
   - Client-side game interface
   - Redux for state management
   - WebSocket communication
   - Custom text rendering

2. **Phoenix LiveView**
   - Admin interface
   - Real-time updates
   - HEEX templates
   - Live components

3. **Styling**
   - TailwindCSS
   - SCSS for custom styling
   - Responsive design
   - Dark mode support

## Key Dependencies

### Elixir Packages
```elixir
# From mix.exs
defp deps do
  [
    {:phoenix, "~> 1.7"},
    {:phoenix_live_view, "~> 0.18"},
    {:phoenix_live_dashboard, "~> 0.7"},
    {:ecto_sql, "~> 3.0"},
    {:postgrex, ">= 0.0.0"},
    {:swoosh, "~> 1.3"},
    {:bcrypt_elixir, "~> 3.0"},
    {:jason, "~> 1.0"}
  ]
end
```

### Node.js Packages
```javascript
// From package.json key dependencies
{
  "react": "^18.0",
  "react-dom": "^18.0",
  "redux": "^4.0",
  "react-redux": "^8.0",
  "@tailwindcss/forms": "^0.5",
  "autoprefixer": "^10.0"
}
```

## Development Tools

### Testing
- ExUnit for Elixir tests
- Jest for JavaScript tests
- Wallaby for end-to-end tests
- ExMachina for factories

### Code Quality
- Credo for Elixir linting
- ESLint for JavaScript
- Prettier for formatting
- Mix format for Elixir formatting

### Monitoring
- Phoenix LiveDashboard
- Prometheus metrics
- Custom telemetry events
- Error tracking (Sentry)

## Deployment

### Container Setup
```dockerfile
# From Dockerfile
FROM elixir:1.14-alpine as builder
# Build steps...

FROM alpine:3.17 as runner
# Runtime configuration...
```

### Environment Variables
```bash
# Critical environment variables
DATABASE_URL=ecto://user:pass@host/database
SECRET_KEY_BASE=your_secret_key
PHX_HOST=your.host
PORT=4000
```

### Release Process
1. Build release
   ```bash
   MIX_ENV=prod mix release
   ```
2. Generate assets
   ```bash
   cd assets && yarn deploy
   ```
3. Run migrations
   ```bash
   _build/prod/rel/ex_venture/bin/ex_venture eval "ExVenture.Release.migrate"
   ```

## Configuration Management

### Runtime Configuration
```elixir
# In config/runtime.exs
config :ex_venture, ExVentureWeb.Endpoint,
  server: true,
  url: [host: System.get_env("PHX_HOST")]
```

### Development Configuration
```elixir
# In config/dev.exs
config :ex_venture, ExVentureWeb.Endpoint,
  debug_errors: true,
  code_reloader: true
```

This document serves as the technical foundation for development and deployment processes.
