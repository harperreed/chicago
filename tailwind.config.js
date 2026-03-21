// ABOUTME: Tailwind CSS v3 configuration for Hugo site
// ABOUTME: Scans layouts and content for class usage, includes typography/forms/aspect-ratio plugins

/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./layouts/**/*.html",
    "./content/**/*.md",
  ],
  plugins: [
    require('@tailwindcss/typography'),
    require('@tailwindcss/forms'),
    require('@tailwindcss/aspect-ratio'),
  ],
}
