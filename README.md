# Harper's Incomplete Chicago Guide

Source for [chicago.harperreed.com](https://chicago.harperreed.com/) — a single-page Hugo site listing Harper's favorite Chicago spots, with a Leaflet map.

## Stack

- [Hugo](https://gohugo.io/) + Tailwind CSS v3 (typography plugin)
- Place data lives in `data/favorites.yaml`; category labels/colors in `data/categories.yaml`
- Deployed on Netlify (`netlify.toml`)

## Develop

```sh
npm install
npm run dev        # builds Tailwind, then hugo server at http://localhost:1313
```

Run `npm run css:watch` in a second terminal if you're editing Tailwind classes.

## Test

```sh
npm test           # builds the site and asserts on the output
```

## Adding a place

Append an entry to `data/favorites.yaml`:

```yaml
- name: "Place Name"
  description: "Why it's good."
  location: "Neighborhood"
  address: "123 W Example Ave, Chicago, IL 60601"
  lat: 41.93181
  lng: -87.70113
  url: "https://example.com/"
  friends: true            # optional ⭐
  type: restaurant         # must exist in data/categories.yaml
  subtype: chinese         # optional; groups restaurants/shops
  keywords: comma, separated, search, terms
```
