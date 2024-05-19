<template>
  <div class="home-container">
    <h1>Welcome to the Home Page</h1>
    <div class="choices">
      <div class="choice-container">
        <router-link to="/streaming" class="choice-link">
          <img src="@/assets/striimu.webp" alt="Streaming" class="choice-image">
          <div class="choice-header">Streaming</div>
        </router-link>
      </div>
      <div class="choice-container">
        <router-link to="/library" class="choice-link">
         <img src="@/assets/logo.png" alt="Library" class="choice-image">
          <div class="choice-header">Watch from Library</div>
        </router-link>
      </div>
    </div>
    <p class="announcement">More features coming soon!</p>
  </div>
</template>

<script>
export default {
  name: 'HomeView'
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
</style>
