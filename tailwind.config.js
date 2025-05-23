/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './app/views/**/*.html.erb',
    './app/helpers/**/*.rb',
    './app/assets/stylesheets/**/*.css',
    './app/javascript/**/*.js'
  ],
  theme: {
    extend: {
      colors: {
        abc: {
          // New color scheme
          primary: '#5A67D8',     // Slate Blue - for headings and buttons
          secondary: '#CBD5E0',    // Cool Gray - for background panels
          highlight: '#319795',   // Teal - for accents
          charcoal: '#2D3748',    // Charcoal - alternative text color
          surface: '#F7FAFC'      // Light background - same as background for consistency
        }
      }
    }
  },
  plugins: [],
}

