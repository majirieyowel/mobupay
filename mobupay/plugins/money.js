import Vue from "vue";

Number.prototype.formatMoney = function (c, d, t) {
  var n = this,
    c = isNaN((c = Math.abs(c))) ? 2 : c,
    d = d == undefined ? "," : d,
    t = t == undefined ? "." : t,
    s = n < 0 ? "-" : "",
    i = parseInt((n = Math.abs(+n || 0).toFixed(c))) + "",
    j = (j = i.length) > 3 ? j % 3 : 0;
  return (
    s +
    (j ? i.substr(0, j) + t : "") +
    i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + t) +
    (c
      ? d +
      Math.abs(n - i)
        .toFixed(c)
        .slice(2)
      : "")
  );
};

function moneyFormat(num, currency = "") {
  num = num.toString();
  if (num === "") {
    num = currency + "0.00";
  } else if (!num.search(currency)) {
    num = currency + parseFloat(num).formatMoney(2, ".", ",");
  } else {
    num =
      currency +
      parseFloat(num.replace(/[^\d\.-]/g, "")).formatMoney(2, ".", ",");
  }
  return num;
}

export default () => {
  Vue.filter("format_money", function (value, divide = true) {
    value = divide ? value / 100 : value
    return moneyFormat(value);
  });
};
