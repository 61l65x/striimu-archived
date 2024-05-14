import Vue from 'vue';
import Router from 'vue-router';
import HomeView from '../views/HomeView.vue';
import LoginView from '../views/LoginView.vue';

Vue.use(Router);

const router = new Router({
  mode: 'history',
  routes: [
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
    }
  ]
});

router.beforeEach((to, from, next) => {
  const token = localStorage.getItem('token');
  if (to.matched.some(record => record.meta.requiresAuth)) {
    if (!token) {
      next({ path: '/login' });
    } else {
      fetch('/auth/validate', {
        headers: {
          'Authorization': token
        }
      })
      .then(response => response.json())
      .then(data => {
        if (data.valid) {
          next();
        } else {
          next({ path: '/login' });
        }
      })
      .catch(() => next({ path: '/login' }));
    }
  } else {
    next();
  }
});

export default router;
