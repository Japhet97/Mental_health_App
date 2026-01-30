/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{vue,js,ts,jsx,tsx}",
  ],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        primary: {
          DEFAULT: '#0A3D0A',
          dark: '#083108',
          light: '#0C4D0C',
        },
        secondary: {
          DEFAULT: '#2ecc71',
          dark: '#27ae60',
          light: '#d4edda',
        },
        accent: {
          green: '#27ae60',
          gray: '#f5f6fa',
        },
        danger: '#e74c3c',
        warning: '#f39c12',
        info: '#3498db',
      }
    },
  },
  plugins: [],
}
