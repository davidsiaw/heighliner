# Simple Example

A minimal Sinatra + Puma web application, started with Heighliner.

## Run it

From this directory:

```bash
heighliner init simple
heighliner up -av
```

Then visit [http://simple.lvh.me](http://simple.lvh.me)

## Files

| File | Purpose |
|---|---|
| `Steerfile` | Heighliner config — tells it which Dockerfile to use, which port to expose, and app params |
| `Dockerfile` | Container image — Ruby 3.3 slim, installs gems, runs Puma |
| `Gemfile` | Ruby dependencies — Sinatra and Puma |
| `config.ru` | Sinatra app + Rack config — routes and Puma entry point |

## Steerfile

```ruby
dockerfile "Dockerfile"

app_params "-e RACK_ENV=development"

expose "4567"
```

- `dockerfile` — which Dockerfile to build
- `app_params` — flags passed to the app when it starts
- `expose` — which port to map to the host
