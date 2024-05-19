<template>
  <div id="app">
    <router-view></router-view>
  </div>
</template>

<script>
export default {
  name: 'App'
};
</script>

<style>
html, body {
  height: 100%;
  margin: 0;
  background-color: #300A24; 
}

#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #ffffff;
  height: 100%;
  display: flex;
  justify-content: center;
  align-items: center;
  background-color: #300A24;
}
</style>