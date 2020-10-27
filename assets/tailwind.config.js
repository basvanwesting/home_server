module.exports = {
  future: {
    removeDeprecatedGapUtilities: true,
    purgeLayersByDefault: true,
  },
  purge: [
    "../**/*.html.eex",
    "../**/*.html.leex",
    "../**/views/**/*.ex",
    "../**/live/**/*.ex",
    "./js/**/*.js"
  ],
  theme: {
    extend: {
      spacing: {
        '72':  '18rem',
        '84':  '21rem',
        '96':  '24rem',
        '128': '32rem',
        '256': '64rem',
      }
    }
  },
  variants: {
    //backgroundColor: ['responsive', 'hover', 'focus', 'active'],
  },
  plugins: [],
}
