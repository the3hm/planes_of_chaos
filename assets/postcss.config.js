module.exports = {
  plugins: [
    require('postcss-advanced-variables'),
    require('postcss-nested'),
    require('tailwindcss')('./tailwind.config.js'),
    require('autoprefixer'),
  ],
}
