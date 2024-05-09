<template>
  <div>
    <h1>Login</h1>
    <form @submit.prevent="handleSubmit">
      <div>
        <label for="username">Username:</label>
        <input id="username" v-model="loginDetails.username" required>
      </div>
      <div>
        <label for="password">Password:</label>
        <input type="password" id="password" v-model="loginDetails.password" required>
      </div>
      <div>
        <input type="checkbox" id="admin" v-model="isAdmin">
        <label for="admin">Login as Admin</label>
      </div>
      <div v-if="isAdmin">
        <label for="sshKey">SSH Key:</label>
        <textarea id="sshKey" v-model="loginDetails.sshKey"></textarea>
      </div>
      <button type="submit">Login</button>
    </form>
  </div>
</template>

<script>
export default {
  data() {
    return {
      isAdmin: false,
      loginDetails: {
        username: '',
        password: '',
        sshKey: ''
      }
    };
  },
  methods: {
    handleSubmit() {
      // Handle the login logic here
      console.log(this.loginDetails);
    }
  }
}
</script>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
}
</style>
