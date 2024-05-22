<!-- src/views/ErrorView.vue -->
<template>
    <div class="error-container">
      <h1>Service Unavailable</h1>
      <p>The service you are trying to access is currently unavailable. Please try again later.</p>
      <router-link to="/">Go back to Home</router-link>
    </div>
  </template>
  
  <script>
  export default {
    name: 'ErrorView',
  };
  </script>
  
  <style scoped>
  .error-container {
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    height: 100vh;
    text-align: center;
    color: #ffffff;
    background-color: #300A24;
  }
  </style>
  