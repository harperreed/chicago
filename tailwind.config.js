// ABOUTME: Tailwind CSS v3 configuration for Hugo site
// ABOUTME: Scans layouts and content for class usage, includes typography plugin

/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./layouts/**/*.html",
    "./content/**/*.md",
  ],
  plugins: [
    require('@tailwindcss/typography'),
  ],
}
