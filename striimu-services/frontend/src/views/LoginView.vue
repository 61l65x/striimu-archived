<template>
  <div class="login-container">
    <div class="login-box">
      <h2>Login</h2>
      <form @submit.prevent="login">
        <div class="input-group">
          <label for="email">Email</label>
          <input v-model="username" type="email" id="email" placeholder="Enter your email" required />
        </div>
        <div class="input-group">
          <label for="password">Password</label>
          <input v-model="password" type="password" id="password" placeholder="Enter your password" required />
        </div>
        <div class="input-group">
          <label for="captcha">CAPTCHA</label>
          <input v-model="captchaInput" type="text" id="captcha" placeholder="Enter CAPTCHA" required />
          <img :src="'data:image/png;base64,' + captchaImage" alt="CAPTCHA" />
          <button type="button" @click="fetchCaptcha">Refresh CAPTCHA</button>
        </div>
        <button type="submit">Login</button>
      </form>
      <button @click="showRegister = true" class="register-button">Register</button>
    </div>
    <div v-if="showRegister" class="register-box">
      <h2>Register</h2>
      <form @submit.prevent="register">
        <div class="input-group">
          <label for="newEmail">Email</label>
          <input v-model="newUsername" type="email" id="newEmail" placeholder="Enter your email" required />
        </div>
        <div class="input-group">
          <label for="newPassword">Password</label>
          <input v-model="newPassword" type="password" id="newPassword" placeholder="Enter a password" required />
        </div>
        <div class="input-group">
          <label for="newCaptcha">CAPTCHA</label>
          <input v-model="captchaInput" type="text" id="newCaptcha" placeholder="Enter CAPTCHA" required />
          <img :src="'data:image/png;base64,' + captchaImage" alt="CAPTCHA" />
          <button type="button" @click="fetchCaptcha">Refresh CAPTCHA</button>
        </div>
        <button type="submit">Register</button>
      </form>
      <div v-if="registrationKey">
        <p>Registration successful! Your key is: {{ registrationKey }}</p>
      </div>
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
      password: '',
      showRegister: false,
      newUsername: '',
      newPassword: '',
      captchaText: '',
      captchaInput: '',
      captchaImage: '',
      registrationKey: '',
    };
  },
  methods: {
    async fetchCaptcha() {
      const response = await fetch('/auth/captcha');
      const data = await response.json();
      this.captchaText = data.captcha_text;
      this.captchaImage = data.captcha_image;
    },
    async login() {
      try {
        const response = await fetch('/auth/login', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({ 
            username: this.username, 
            password: this.password, 
            captcha_text: this.captchaText, 
            captcha_input: this.captchaInput 
          })
        });
        const data = await response.json();
        if (data.token) {
          localStorage.setItem('token', data.token);
          this.$router.push('/'); // Redirect to home
        } else {
          alert(data.message);
          if (data.message === 'Invalid CAPTCHA') {
            this.fetchCaptcha(); // Fetch new CAPTCHA on failure
          }
        }
      } catch (error) {
        console.error('Error:', error);
      }
    },
    async register() {
    try {
      const response = await fetch('/auth/register', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ 
          username: this.newUsername, 
          password: this.newPassword, 
          captcha_text: this.captchaText, 
          captcha_input: this.captchaInput 
        })
      });
      const data = await response.json();
      if (response.ok) {
        localStorage.setItem('token', data.token); // Store the token after registration
        this.$router.push('/'); // Redirect to home after registration
      } else {
        alert(data.message);
        if (data.message === 'Invalid CAPTCHA') {
          this.fetchCaptcha(); // Fetch new CAPTCHA on failure
        }
      }
      } catch (error) {
        console.error('Error:', error);
      }
    },
  },
  created() {
    this.fetchCaptcha();
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
