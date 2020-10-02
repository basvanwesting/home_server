module.exports = {
  future: {
    removeDeprecatedGapUtilities: true,
  },
  purge: [
    "../**/*.html.eex",
    "../**/*.html.leex",
    "../**/views/**/*.ex",
    "../**/live/**/*.ex",
    "./js/**/*.js"
  ],
  theme: {
    extend: {},
  },
  variants: {
    //backgroundColor: ['responsive', 'hover', 'focus', 'active'],
  },
  plugins: [],
}
