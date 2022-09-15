// Styles
import '@mdi/font/css/materialdesignicons.css'
import 'vuetify/styles'

// Vuetify
import { createVuetify } from 'vuetify'

export default createVuetify({
  theme: {
    defaultTheme: 'casperDev',
    themes: {
      casperDev: {
        dark: true,
        colors: {
          background: '#03045E',
          surface: '#0077B6',
          primary: '#00B4D8'
        }
      }
    }
  }
})
