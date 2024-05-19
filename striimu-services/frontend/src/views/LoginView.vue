<template>
  <div class="login-container">
    <div class="login-box">
      <h2>Login</h2>
      <form @submit.prevent="login">
        <div class="input-group">
          <label for="username">Username</label>
          <input v-model="username" type="text" id="username" placeholder="Enter your username" required />
        </div>
        <div class="input-group">
          <label for="key">Key</label>
          <input v-model="key" type="text" id="key" placeholder="Enter your key" required />
        </div>
        <div class="remember-me">
          <input v-model="rememberMe" type="checkbox" id="rememberMe" />
          <label for="rememberMe">Remember Me</label>
        </div>
        <button type="submit">Login</button>
      </form>
      <button @click="showRegister = true" class="register-button">Register</button>
    </div>
    <div v-if="showRegister" class="register-box">
      <h2>Register</h2>
      <form @submit.prevent="register">
        <div class="input-group">
          <label for="newUsername">Username</label>
          <input v-model="newUsername" type="text" id="newUsername" placeholder="Enter a username" required />
        </div>
        <div class="input-group">
          <label for="newPassword">Password</label>
          <input v-model="newPassword" type="password" id="newPassword" placeholder="Enter a password" required />
        </div>
        <button type="submit">Register</button>
      </form>
      <button @click="showRegister = false" class="cancel-button">Cancel</button>
    </div>
  </div>
</template>

<script>
export default {
  name: 'LoginView',
  data() {
    return {
      username: '',
      key: '',
      rememberMe: false,
      showRegister: false,
      newUsername: '',
      newPassword: '',
    };
  },
  methods: {
    async login() {
      try {
        const response = await fetch('http://localhost:3000/auth/login', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({ username: this.username, key: this.key })
        });
        const data = await response.json();
        if (data.token) {
          localStorage.setItem('token', data.token);
          if (this.rememberMe) {
            localStorage.setItem('rememberMe', 'true');
          } else {
            localStorage.removeItem('rememberMe');
          }
          this.$router.push('/'); // Redirect to home
        } else {
          alert(data.message);
        }
      } catch (error) {
        console.error('Error:', error);
      }
    },
    async register() {
      try {
        const response = await fetch('http://localhost:3000/auth/register', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({ username: this.newUsername, password: this.newPassword })
        });
        const data = await response.json();
        if (response.ok) {
          alert(`Registration successful! Your key: ${data.key}`);
          this.showRegister = false;
        } else {
          alert(data.message);
        }
      } catch (error) {
        console.error('Error:', error);
      }
    },
    skipLogin() {
      this.$router.push('/');
    }
  }
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
