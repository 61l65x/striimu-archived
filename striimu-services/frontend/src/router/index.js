import { createRouter, createWebHistory } from 'vue-router';
import HomeView from '../views/HomeView.vue';
import LoginView from '../views/LoginView.vue';
import ErrorView from '../views/ErrorView.vue'; // Ensure you have this view

const apiBaseUrl = process.env.VUE_APP_BACKEND_URL || 'http://backend:3000';

const routes = [
  {
    path: '',
    name: 'HomeView',
    component: HomeView,
    meta: { requiresAuth: true }
  },
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
    path: '/stremio-web',
    name: 'StremioWeb',
    meta: { requiresAuth: true },
    beforeEnter: async (to, from, next) => {
      const token = localStorage.getItem('token');
      if (!token) {
        next('/login');
      } else {
        next();
      }
    }
  },
  {
    path: '/jellyfin',
    name: 'Jellyfin',
    meta: { requiresAuth: true },
    beforeEnter: async (to, from, next) => {
      const token = localStorage.getItem('token');
      if (!token) {
        next('/login');
      } else {
        next();
      }
    }
  },
  {
    path: '/error',
    name: 'ErrorView',
    component: ErrorView,
    props: true
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

const isDevelopmentMode = false; // Set this to false to enable authentication checks

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
          const response = await fetch(`${apiBaseUrl}/auth/validate`, {
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
