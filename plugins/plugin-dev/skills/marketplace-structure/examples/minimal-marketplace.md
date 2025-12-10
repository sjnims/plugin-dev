# Minimal Marketplace Example

A single-plugin marketplace with only required fields.

## Use Case

- Quick setup for distributing one plugin
- Minimal configuration overhead
- Local development and testing

## Directory Structure

```text
my-marketplace/
├── .claude-plugin/
│   └── marketplace.json
└── plugins/
    └── my-plugin/
        └── .claude-plugin/
            └── plugin.json
```

## marketplace.json

```json
{
  "name": "my-marketplace",
  "owner": {
    "name": "Your Name"
  },
  "plugins": [
    {
      "name": "my-plugin",
      "source": "./plugins/my-plugin"
    }
  ]
}
```

## Plugin's plugin.json

The plugin must have its own manifest since `strict: true` is the default:

```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "description": "A simple plugin"
}
```

## Installation

```bash
# Local testing
/plugin marketplace add ./my-marketplace

# After publishing to GitHub
/plugin marketplace add your-username/my-marketplace
```

## Extending to Multiple Plugins

Add more plugins to the array:

```json
{
  "name": "my-marketplace",
  "owner": {
    "name": "Your Name"
  },
  "plugins": [
    {
      "name": "plugin-one",
      "source": "./plugins/plugin-one"
    },
    {
      "name": "plugin-two",
      "source": "./plugins/plugin-two"
    }
  ]
}
```
