<template>
  <div class="home-container">
    <h1>Welcome to the Home Page</h1>
    <div class="choices">
      <div class="choice-container">
        <router-link to="/stremio-web" class="choice-link">
          <img src="@/assets/stremio_logo.jpg" alt="Streaming" class="choice-image">
          <div class="choice-header">Streaming</div>
        </router-link>
      </div>
      <div class="choice-container">
        <router-link to="/jellyfin" class="choice-link">
          <img src="@/assets/jellyfin_logo.png" alt="Library" class="choice-image">
          <div class="choice-header">Watch from Library</div>
        </router-link>
      </div>
    </div>
    <p class="announcement">More features coming soon!</p>
    <button @click="logout" class="logout-button">Logout</button>
  </div>
</template>


<script>
export default {
  name: 'HomeView',
  methods: {
    logout() {
      localStorage.removeItem('token'); // Remove the token from local storage
      this.$router.push('/login'); // Redirect to the login page
    }
  }
};
</script>


<style scoped>
.home-container {
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  height: 100vh;
  text-align: center;
  color: #ffffff;
  background-color: #300A24;
}

.choices {
  display: flex;
  justify-content: space-around;
  width: 100%;
  max-width: 800px;
  margin: 20px 0;
}

.choice-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  width: 45%;
  background-color: rgba(255, 255, 255, 0.1);
  border-radius: 10px;
  overflow: hidden;
  transition: transform 0.3s;
}

.choice-container:hover {
  transform: scale(1.05);
}

.choice-link {
  text-decoration: none;
  color: inherit;
}

.choice-image {
  width: 100%;
  height: 200px; /* Set a fixed height for uniformity */
  object-fit: cover; /* Ensure the image covers the area */
  height: auto;
}

.choice-header {
  padding: 15px;
  background-color: #3498db;
  color: white;
  font-size: 18px;
  width: 100%;
  text-align: center;
}

.announcement {
  margin-top: 30px;
  font-size: 18px;
  color: #e0e0e0;
}

.logout-button {
  margin-top: 20px;
  padding: 10px 20px;
  font-size: 16px;
  color: #ffffff;
  background-color: #e74c3c;
  border: none;
  border-radius: 5px;
  cursor: pointer;
}

.logout-button:hover {
  background-color: #c0392b;
}
</style>
