export default function ({ store, route }) {

  if (route.name == "dashboard") {
    store.commit('setDisplayHeaderBalance', false)
  } else {
    store.commit('setDisplayHeaderBalance', true)
  }

  // set breadcrumbs
  if (route.params && route.params.dashboard) {
    let { dashboard } = { ...route.params };
    if (Object.keys(route.meta[0]).length !== 0) {
      let breadcrumbs = route.meta[0].breadcrumbs;
      breadcrumbs.map((item) => {
        if (item.to && item.to.params) {
          item.to.params = dashboard;
          item.exact = true;
        }
      });
      store.commit("setBreadcrumb", [...breadcrumbs]);
    } else {
      store.commit("setBreadcrumb", []);
    }
  }
}
