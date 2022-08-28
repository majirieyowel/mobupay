import colors from "vuetify/es5/util/colors";

export default {
  // Global page headers: https://go.nuxtjs.dev/config-head
  head: {
    titleTemplate: "%s - mobupay",
    title: "mobupay",
    htmlAttrs: {
      lang: "en",
    },
    meta: [
      { charset: "utf-8" },
      { name: "viewport", content: "width=device-width, initial-scale=1" },
      { hid: "description", name: "description", content: "" },
      { name: "format-detection", content: "telephone=no" },
    ],
    link: [{ rel: "icon", type: "image/x-icon", href: "/favicon-32x32.png" }],
  },

  // Global CSS: https://go.nuxtjs.dev/config-css
  css: ["@/assets/css/global.scss"],

  // Plugins to run before rendering page: https://go.nuxtjs.dev/config-plugins
  plugins: ["@/plugins/money.js"],

  router: {
    middleware: ["user_agent_detect"],
  },

  // Auto import components: https://go.nuxtjs.dev/config-components
  components: [
    // Equivalent to { path: '~/components' }
    "~/components",
    { path: "~/components/onboarding", extensions: ["vue"] },
  ],

  // Modules for dev and build (recommended): https://go.nuxtjs.dev/config-modules
  buildModules: [
    // https://go.nuxtjs.dev/vuetify
    "@nuxtjs/vuetify",
    "@nuxtjs/moment",
  ],

  // Modules: https://go.nuxtjs.dev/config-modules
  modules: ["@nuxtjs/axios", "@nuxtjs/auth-next", "vue-toastification/nuxt"],

  auth: {
    strategies: {
      local: {
        scheme: "refresh",
        token: {
          property: "data.access_token",
          maxAge: 60,
          global: true,
          type: "Bearer",
        },
        refreshToken: {
          property: "data.refresh_token",
          data: "refresh_token",
          maxAge: 60 * 60,
        },
        user: {
          property: "data.user",
          // autoFetch: true,
        },
        endpoints: {
          login: { url: "/session/login", method: "post" },
          refresh: { url: "/session/refresh", method: "post" },
          user: { url: "/user", method: "get" },
          logout: { url: "/session/logout", method: "delete" },
        },
        // autoLogout: false
      },
    },
    redirect: {
      logout: "/login",
    },
  },

  toast: {
    position: "top-right",
    timeout: 7048,
    closeOnClick: true,
    pauseOnFocusLoss: false,
    pauseOnHover: true,
    draggable: false,
    draggablePercent: 0.6,
    showCloseButtonOnHover: false,
    hideProgressBar: true,
    closeButton: "button",
    icon: false,
    rtl: false,
  },

  // Vuetify module configuration: https://go.nuxtjs.dev/config-vuetify
  vuetify: {
    customVariables: ["~/assets/variables.scss"],
    theme: {
      dark: false,
      themes: {
        dark: {
          primary: colors.blue.darken2,
          accent: colors.grey.darken3,
          secondary: colors.amber.darken3,
          info: colors.teal.lighten1,
          warning: colors.amber.base,
          error: colors.deepOrange.accent4,
          success: colors.green.accent3,
        },
      },
    },
  },

  axios: {
    // proxy: true
    baseURL: "http://localhost:4000/api/v1",
  },
  // loading: false,

  loading: {
    color: "#87d37c",
    height: "2px",
    throttle: 0,
    continuous: true,
  },

  env: {
    ipURL: "https://httpbin.org/ip",
    paystackBanksEndpoint: "https://api.paystack.co/bank",
  },

  // Build Configuration: https://go.nuxtjs.dev/config-build
  build: {},
};
