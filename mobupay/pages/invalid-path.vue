<template>
  <div id="main">
    <div class="fof">
      <h1>Error 404</h1>
      <p>You seem to be lost.</p>
    </div>
  </div>
</template>

<script>
export default {
  name: "invalid-path",
};
</script>

<style scoped>
* {
  transition: all 0.6s;
}

html {
  height: 100%;
}

body {
  font-family: "Lato", sans-serif;
  color: #888;
  margin: 0;
}

#main {
  display: table;
  width: 100%;
  min-height: 70vh;
  text-align: center;
}

.fof {
  display: table-cell;
  vertical-align: middle;
}

.fof h1 {
  font-size: 30px;
  display: inline-block;
  padding-right: 12px;
  animation: type 0.5s alternate infinite;
}

.fof p {
  font-size: 13px;
}

@keyframes type {
  from {
    box-shadow: inset -3px 0px 0px #888;
  }
  to {
    box-shadow: inset -3px 0px 0px transparent;
  }
}

@media (min-width: 767px) {
  .fof h1 {
    font-size: 50px;
  }

  .fof p {
    font-size: 16px;
  }
}
</style>