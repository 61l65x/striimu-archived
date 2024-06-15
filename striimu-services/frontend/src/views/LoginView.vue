<template>
  <div>
    <div v-if="showRegister">
      <form @submit.prevent="register">
        <div class="input-group">
          <label for="newUsername">Username</label>
          <input v-model="newUsername" type="text" id="newUsername" required />
        </div>
        <div class="input-group">
          <label for="newPassword">Password</label>
          <input v-model="newPassword" type="password" id="newPassword" required />
        </div>
        <div class="input-group">
          <label for="accessToken">Access Token</label>
          <input v-model="accessToken" type="text" id="accessToken" required />
        </div>
        <button type="submit">Register</button>
      </form>
      <button @click="showRegister = false" class="cancel-button">Cancel</button>
    </div>
    <div v-else>
      <form @submit.prevent="login">
        <div class="input-group">
          <label for="username">Username</label>
          <input v-model="username" type="text" id="username" required />
        </div>
        <div class="input-group">
          <label for="password">Password</label>
          <input v-model="password" type="password" id="password" required />
        </div>
        <button type="submit">Login</button>
      </form>
      <button @click="showRegister = true" class="register-button">Register</button>
    </div>
  </div>
</template>

<script>
const apiBaseUrl = 'http://backend:3000';

export default {
  name: 'LoginView',
  data() {
    return {
      username: '',
      password: '',
      newUsername: '',
      newPassword: '',
      accessToken: '',
      showRegister: false,
    };
  },
  methods: {
    async login() {
      try {
        const response = await fetch(`${apiBaseUrl}/auth/login`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            username: this.username,
            password: this.password,
          }),
        });
        const data = await response.json();
        if (response.ok) {
          localStorage.setItem('token', data.token); // Store the token after login
          this.$router.push('/'); // Redirect to home after login
        } else {
          alert(data.message);
        }
      } catch (error) {
        console.error('Error:', error);
      }
    },
    async register() {
      try {
        const response = await fetch(`${apiBaseUrl}/auth/register`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            username: this.newUsername,
            password: this.newPassword,
            access_token: this.accessToken,
          }),
        });
        const data = await response.json();
        if (response.ok) {
          localStorage.setItem('token', data.token); // Store the token after registration
          this.$router.push('/'); // Redirect to home after registration
        } else {
          alert(data.message);
        }
      } catch (error) {
        console.error('Error:', error);
      }
    },
  },
};
</script>


<style scoped>
html, body, #app {
  height: 100%;
  margin: 0;
  overflow: hidden; /* Prevent scrolling */
}

.login-container {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100vh;
  width: 100vw;
  background-size: contain;
  background-position: center;
  background-repeat: no-repeat;
}

.login-box, .register-box {
  padding: 30px;
  border-radius: 10px;
  box-shadow: 0 4px 8px rgba(255, 255, 255, 0.042);
  text-align: center;
  max-width: 400px;
  width: 100%;
  background-color: #300A24;
}

h2 {
  margin-bottom: 20px;
  color: #ffffff;
}

.input-group {
  margin-bottom: 15px;
  text-align: left;
}

.input-group label {
  display: block;
  margin-bottom: 5px;
  color: #ffffff;
}

.input-group input {
  width: 100%;
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 5px;
}

.remember-me {
  display: flex;
  align-items: center;
  margin-bottom: 15px;
}

.remember-me input {
  margin-right: 10px;
}

button {
  width: 100%;
  padding: 10px;
  border: none;
  border-radius: 5px;
  background-color: #451438;
  color: white;
  font-size: 16px;
  cursor: pointer;
}

button:hover {
  background-color: #5e1d50;
}

.register-button {
  margin-top: 15px;
  background-color: #451438;
}

.register-button:hover {
  background-color: #5e1d50;
}

.cancel-button {
  margin-top: 15px;
  background-color: #e74c3c;
}

.cancel-button:hover {
  background-color: #c0392b;
}
</style>
