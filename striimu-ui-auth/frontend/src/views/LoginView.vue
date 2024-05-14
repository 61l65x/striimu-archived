<template>
  <div>
    <input v-model="key" placeholder="Enter your key" />
    <button @click="login">Login</button>
  </div>
</template>

<script>
export default {
  name: 'LoginView',
  data() {
    return {
      key: ''
    };
  },
  methods: {
    async login() {
      try {
        const response = await fetch('/auth/login', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({ key: this.key })
        });
        const data = await response.json();
        if (data.token) {
          localStorage.setItem('token', data.token);
          this.$router.push('/'); // Redirect to home
        } else {
          alert('Invalid key');
        }
      } catch (error) {
        console.error('Error:', error);
      }
    }
  }
};
</script>

<style scoped>
/* Add styles specific to the login component here */
</style>
