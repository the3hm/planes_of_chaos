# ExVenture Technical Context

## Development Environment

### Requirements
- Elixir 1.18.3
- Erlang/OTP 27
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
      # Core Phoenix + HTML + LiveView
      {:phoenix, "~> 1.7.21"},
      {:phoenix_ecto, "~> 4.6"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_dashboard, "~> 0.8.6"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 1.0"},
      {:phoenix_pubsub, "~> 2.0"},

      # UI & Styling
      {:tailwind, "~> 0.3.1"},
      {:heroicons,
      github: "tailwindlabs/heroicons",
      tag: "v2.1.5",
      app: false,
      compile: false,
      sparse: "optimized"},
      {:petal_components, "~> 3.0"},

      # Storage & Uploads
      {:stein, "~> 0.5"},
      {:stein_storage, git: "https://github.com/smartlogic/stein_storage.git", branch: "main"},

      # Database & Ecto
      {:ecto_sql, "~> 3.12"},
      {:postgrex, ">= 0.0.0"},

      # Mailer
      {:swoosh, "~> 1.18"},
      {:gen_smtp, "~> 1.2"},

      # Instrumentation
      {:telemetry, "~> 1.3"},
      {:telemetry_metrics, "~> 0.4"},
      {:telemetry_poller, "~> 0.4"},

      # HTTP / Server
      {:plug, "~> 1.14"},
      {:plug_cowboy, "~> 2.7"},
      {:ranch, "~> 2.2", override: true},

      # Misc Utilities
      {:elias, "~> 0.2"},
      {:gettext, "~> 0.26.2"},
      {:jason, "~> 1.4"},
      {:logster, "~> 1.0"},
      {:porcelain, "~> 2.0"},
      {:elixir_uuid, "~> 1.2"},
      {:vapor, "~> 0.10.0"},

      # Kalevala MUD Engine
      {:kalevala, path: "../kalevala", override: true}, # Local fork with custom behavior tree + modular brains

      # Dev/Test Tools
      {:credo, "~> 1.7", only: [:dev, :test]},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false}
    ]
  end
```

### Node.js Packages
```javascript
// From package.json key dependencies
{
   "react": "^18.2.0",
   "react-dom": "^18.2.0",
   "redux": "^4.2.1",
   "react-redux": "^8.1.1",
   "@tailwindcss/forms": "^0.5.6",
   "autoprefixer": "^10.4.13",
   "postcss": "^8.4.21",
   "tailwindcss": "^3.3.2"
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
- Telemetry hooks available for PromEx or custom monitoring (Prometheus integration deferred)
- Custom telemetry events
- Error tracking (Sentry)

## Dependency Strategy

- Elixir and Node.js dependencies are locked and committed to Git.
- Do **not** regenerate `mix.exs` or `package.json` without confirming compatibility with:
  - Elixir 1.18.3 / OTP 27
  - Phoenix 1.7.21
  - LiveView 0.20+
- Avoid dependency downgrades. If updates are required, preserve working lockfile state and validate tests.


## Deployment

### Container Setup
```dockerfile
# From Dockerfile
FROM elixir:1.18.3-alpine as builder
# Build steps...

FROM alpine:3.17 as runner
# Runtime configuration...
```

### Environment Variables
```bash
# Critical environment variables
DATABASE_URL=ecto://postgres:postgres@localhost/ex_venture_dev
SECRET_KEY_BASE=7vlmUKp7Nf6V446taT43bflGdeSm/z8p/ZTNHbRpbskbTpxUOKnBoJ6d8Nn/oC7b
PHX_HOST=localhost
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
! Do not remove petal_components, tailwind, or heroicons from mix.exs. Use them in UI design.

This document serves as the technical foundation for development and deployment processes.
