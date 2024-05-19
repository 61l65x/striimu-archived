import { createRouter, createWebHistory } from 'vue-router';
import HomeView from '../views/HomeView.vue';
import LoginView from '../views/LoginView.vue';

const routes = [
  {
    path: '/',
    name: 'HomeView',
    component: HomeView,
    meta: { requiresAuth: true }
  },
  {
    path: '/login',
    name: 'LoginView',
    component: LoginView
  },
  {
    path: '/:catchAll(.*)',
    redirect: '/login'
  }
];

const router = createRouter({
  history: createWebHistory('/'), // Set the base URL to root
  routes
});

const isDevelopmentMode = true; // Set this to false to enable authentication checks

router.beforeEach(async (to, from, next) => {
  if (isDevelopmentMode) {
    next(); // Bypass authentication in development mode
  } else {
    const token = localStorage.getItem('token');
    if (to.matched.some(record => record.meta.requiresAuth)) {
      if (!token) {
        next({ path: '/login' });
      } else {
        try {
          const response = await fetch('/auth/validate', {
            headers: {
              'Authorization': `Bearer ${token}`
            }
          });
          const data = await response.json();
          if (response.ok && data.valid) {
            next();
          } else {
            localStorage.removeItem('token'); // Remove invalid token
            next({ path: '/login' });
          }
        } catch (error) {
          console.error('Token validation error:', error);
          localStorage.removeItem('token'); // Remove invalid token
          next({ path: '/login' });
        }
      }
    } else {
      next();
    }
  }
});

export default router;
