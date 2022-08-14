import Vue from "vue";

export default () => {
  Vue.filter("format_money", function (value) {
    return (value / 100).toFixed(2);
  });
};
